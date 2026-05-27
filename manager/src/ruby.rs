use clap::{Subcommand, ValueEnum};
use std::env;
use std::process;
use std::sync::Arc;
use std::sync::atomic::Ordering;
use std::thread;

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum RunResult {
    Success,
    Failure,
}

impl std::process::Termination for RunResult {
    fn report(self) -> std::process::ExitCode {
        match self {
            Self::Success => std::process::ExitCode::SUCCESS,
            Self::Failure => std::process::ExitCode::FAILURE,
        }
    }
}

#[derive(Clone, Debug)]
pub struct RerunConfig {
    pub runs: u32,
    pub jobs: u32,
}

struct CapturedOutput {
    stdout: Vec<u8>,
    stderr: Vec<u8>,
}

impl RerunConfig {
    pub fn execute<F>(&self, spawn_function: F) -> RunResult
    where
        F: Fn(bool) -> process::Child + Send + Sync + 'static,
    {
        if self.runs == 1 {
            self.execute_single(&spawn_function)
        } else if self.jobs == 1 {
            self.execute_sequential(&spawn_function)
        } else {
            self.execute_concurrent(spawn_function)
        }
    }

    fn execute_single<F>(&self, spawn_function: &F) -> RunResult
    where
        F: Fn(bool) -> process::Child,
    {
        let mut child = spawn_function(false);
        let status = child.wait().expect("Failed to wait for child process");

        if status.success() {
            RunResult::Success
        } else {
            RunResult::Failure
        }
    }

    fn execute_sequential<F>(&self, spawn_function: &F) -> RunResult
    where
        F: Fn(bool) -> process::Child,
    {
        let mut exit_counts: std::collections::BTreeMap<i32, u32> =
            std::collections::BTreeMap::new();

        for run_number in 1..=self.runs {
            log::info!("Run {}/{}", run_number, self.runs);
            let (status, output) = Self::run_with_capture(spawn_function);
            let exit_code = status.code().unwrap_or(-1);

            *exit_counts.entry(exit_code).or_insert(0) += 1;

            if !status.success() {
                Self::print_failure_output(run_number, &output);
            }
        }

        Self::print_summary(&exit_counts);
        Self::result_from_exit_counts(&exit_counts)
    }

    fn run_with_capture<F>(spawn_function: &F) -> (process::ExitStatus, CapturedOutput)
    where
        F: Fn(bool) -> process::Child,
    {
        use std::io::Read;

        let mut child = spawn_function(true);

        let mut stdout_handle = child.stdout.take();
        let mut stderr_handle = child.stderr.take();

        let mut stdout = Vec::new();
        let mut stderr = Vec::new();

        if let Some(ref mut handle) = stdout_handle {
            let _ = handle.read_to_end(&mut stdout);
        }
        if let Some(ref mut handle) = stderr_handle {
            let _ = handle.read_to_end(&mut stderr);
        }

        let status = child.wait().expect("Failed to wait for child process");

        (status, CapturedOutput { stdout, stderr })
    }

    fn print_failure_output(run_number: u32, output: &CapturedOutput) {
        use std::io::Write;

        eprintln!("--- Run {} failed ---", run_number);
        if !output.stdout.is_empty() {
            let _ = std::io::stderr().write_all(&output.stdout);
        }
        if !output.stderr.is_empty() {
            let _ = std::io::stderr().write_all(&output.stderr);
        }
        eprintln!("--- End run {} ---", run_number);
    }

    fn result_from_exit_counts(exit_counts: &std::collections::BTreeMap<i32, u32>) -> RunResult {
        if exit_counts.keys().all(|&code| code == 0) {
            RunResult::Success
        } else {
            RunResult::Failure
        }
    }

    fn print_summary(exit_counts: &std::collections::BTreeMap<i32, u32>) {
        eprintln!("ExitStatuses:");
        for (exit_code, count) in exit_counts {
            eprintln!("  {}: {}", exit_code, count);
        }
    }

    fn execute_concurrent<F>(&self, spawn_function: F) -> RunResult
    where
        F: Fn(bool) -> process::Child + Send + Sync + 'static,
    {
        let completed = Arc::new(std::sync::atomic::AtomicU32::new(0));
        let exit_counts: Arc<std::sync::Mutex<std::collections::BTreeMap<i32, u32>>> =
            Arc::new(std::sync::Mutex::new(std::collections::BTreeMap::new()));
        let total_runs = self.runs;
        let spawn_function = Arc::new(spawn_function);

        let mut handles = vec![];

        for _ in 0..self.jobs {
            let completed = Arc::clone(&completed);
            let exit_counts = Arc::clone(&exit_counts);
            let spawn_function = Arc::clone(&spawn_function);

            let handle = thread::spawn(move || {
                Self::worker_thread(completed, exit_counts, spawn_function, total_runs);
            });
            handles.push(handle);
        }

        for handle in handles {
            handle.join().unwrap();
        }

        let exit_counts = exit_counts.lock().unwrap();
        Self::print_summary(&exit_counts);
        Self::result_from_exit_counts(&exit_counts)
    }

    fn worker_thread<F>(
        completed: Arc<std::sync::atomic::AtomicU32>,
        exit_counts: Arc<std::sync::Mutex<std::collections::BTreeMap<i32, u32>>>,
        spawn_function: Arc<F>,
        total_runs: u32,
    ) where
        F: Fn(bool) -> process::Child,
    {
        loop {
            let run_number = completed.fetch_add(1, Ordering::SeqCst) + 1;
            if run_number > total_runs {
                break;
            }

            log::info!("Run {}/{}", run_number, total_runs);

            let (status, output) = Self::run_with_capture(spawn_function.as_ref());
            let exit_code = status.code().unwrap_or(-1);

            {
                let mut counts = exit_counts.lock().unwrap();
                *counts.entry(exit_code).or_insert(0) += 1;
            }

            if !status.success() {
                Self::print_failure_output(run_number, &output);
            }
        }
    }
}

#[derive(Clone, ValueEnum)]
pub enum Runtime {
    Host,
    #[value(name = "container-3.3")]
    Ruby33,
    #[value(name = "container-3.4")]
    Ruby34,
    #[value(name = "container-4.0")]
    Ruby40,
}

#[derive(Subcommand)]
pub enum Command {
    /// Prepare ruby directory (VERSION and LICENSE files)
    Prepare,
    /// Execute ruby binary
    Exec {
        /// Arguments to pass to ruby
        arguments: Vec<String>,
    },
    /// Execute bundle command
    Bundle {
        /// Arguments to pass to bundle
        arguments: Vec<String>,
    },
    /// Run rspec commands
    Rspec {
        #[command(subcommand)]
        action: rspec::Command,
    },
    /// Run mutant commands
    Mutant {
        #[command(subcommand)]
        action: mutant::Command,
    },
    /// Run rubocop
    Rubocop {
        /// Additional arguments
        arguments: Vec<String>,
    },
    /// Verify quick_start example works correctly
    QuickStartVerify,
    /// Verify the rails_example hooks under a Rails version and database
    RailsVerify {
        /// Rails version under test
        #[arg(long)]
        rails: RailsVersion,
        /// Database the hooks isolate
        #[arg(long)]
        database: Database,
    },
    /// Run the rails_example verification steps against an already-provisioned
    /// database (internal: re-invoked under `pg-ephemeral run-env`).
    RailsVerifySteps,
}

#[derive(Clone, Copy, ValueEnum)]
pub enum RailsVersion {
    #[value(name = "7.2")]
    V72,
    #[value(name = "8.0")]
    V80,
    #[value(name = "8.1")]
    V81,
}

impl RailsVersion {
    // Gem requirement passed to the rails_example Gemfile via RAILS_VERSION.
    fn requirement(self) -> &'static str {
        match self {
            Self::V72 => "~> 7.2.0",
            Self::V80 => "~> 8.0.0",
            Self::V81 => "~> 8.1.0",
        }
    }
}

#[derive(Clone, Copy, ValueEnum)]
pub enum Database {
    Postgresql,
    Sqlite,
}

impl Database {
    // Value of DB_ADAPTER, read by config/database.yml and config/mutant/hooks.rb.
    fn adapter(self) -> &'static str {
        match self {
            Self::Postgresql => "postgresql",
            Self::Sqlite => "sqlite3",
        }
    }
}

pub mod rspec {
    use clap::Subcommand;

    #[derive(Subcommand)]
    pub enum Command {
        /// Run unit specs
        Unit {
            /// Additional arguments
            arguments: Vec<String>,
        },
        /// Run integration specs
        Integration {
            #[command(subcommand)]
            action: Option<integration::Command>,
            /// Additional arguments (only when running all integration tests)
            #[arg(trailing_var_arg = true)]
            arguments: Vec<String>,
        },
    }

    pub mod integration {
        use clap::Subcommand;

        #[derive(Subcommand)]
        pub enum Command {
            /// Run misc integration specs
            Misc {
                /// Additional arguments
                arguments: Vec<String>,
            },
            /// Run minitest integration specs
            Minitest {
                /// Additional arguments
                arguments: Vec<String>,
            },
            /// Run rspec integration specs
            Rspec {
                /// Additional arguments
                arguments: Vec<String>,
            },
            /// Run generation integration specs
            Generation {
                /// Additional arguments
                arguments: Vec<String>,
            },
        }
    }
}

pub mod mutant {
    use clap::Subcommand;

    #[derive(Subcommand)]
    pub enum Command {
        /// Run mutant test
        Test {
            /// Additional arguments
            arguments: Vec<String>,
        },
        /// Run mutant run
        Run {
            /// Additional arguments
            arguments: Vec<String>,
        },
    }
}

impl Command {
    pub fn run(self, runtime: Runtime, rerun_config: RerunConfig) -> RunResult {
        runtime.run(self, rerun_config)
    }
}

impl Runtime {
    pub fn run(self, command: Command, rerun_config: RerunConfig) -> RunResult {
        match command {
            Command::QuickStartVerify => self.run_quick_start_verify(),
            Command::RailsVerify { rails, database } => Self::run_rails_verify(rails, database),
            Command::RailsVerifySteps => Self::run_rails_verify_steps(&[]),
            _ => match self {
                Self::Host => self.run_host(command, rerun_config),
                Self::Ruby33 => self.run_container("docker.io/library/ruby:3.3-alpine", command),
                Self::Ruby34 => self.run_container("docker.io/library/ruby:3.4-alpine", command),
                Self::Ruby40 => self.run_container("docker.io/library/ruby:4.0-alpine", command),
            },
        }
    }

    fn run_quick_start_verify(self) -> RunResult {
        // Run bundle install first
        log::info!("QuickStartVerify: Running bundle install");
        let bundle_status = process::Command::new("bundle")
            .arg("install")
            .current_dir("quick_start")
            .status()
            .expect("Failed to run bundle install");

        if !bundle_status.success() {
            eprintln!("QuickStartVerify FAILED: bundle install failed");
            return RunResult::Failure;
        }

        let mutant_args = &[
            "mutant",
            "run",
            "--use",
            "rspec",
            "--usage",
            "opensource",
            "--require",
            "./lib/person",
            "Person#adult?",
        ];

        // Run 1: Without covering spec, expect mutations to survive (exit 1)
        log::info!(
            "QuickStartVerify: Running without covering spec (expecting mutations to survive)"
        );
        let status_without = self.run_quick_start_command(mutant_args, false);
        if status_without.success() {
            eprintln!(
                "QuickStartVerify FAILED: Expected mutations to survive without covering spec"
            );
            return RunResult::Failure;
        }
        log::info!("QuickStartVerify: Mutations survived as expected");

        // Run 2: With covering spec, expect 100% coverage (exit 0)
        log::info!("QuickStartVerify: Running with covering spec (expecting 100% coverage)");
        let status_with = self.run_quick_start_command(mutant_args, true);
        if !status_with.success() {
            eprintln!("QuickStartVerify FAILED: Expected 100% coverage with covering spec");
            return RunResult::Failure;
        }
        log::info!("QuickStartVerify: 100% coverage achieved as expected");

        RunResult::Success
    }

    fn run_quick_start_command(
        &self,
        args: &[&str],
        with_covering_spec: bool,
    ) -> process::ExitStatus {
        let mut command = process::Command::new("bundle");
        command.arg("exec").args(args).current_dir("quick_start");

        if with_covering_spec {
            command.env("WITH_COVERING_SPEC", "1");
        }

        let mut child = command.spawn().expect("Failed to spawn process");
        child.wait().expect("Failed to wait for process")
    }

    // Verify the documented Rails hooks (docs/rails.md, mirrored in
    // rails_example/config/mutant/hooks_*.rb) actually isolate parallel workers
    // for a given Rails version and database. PostgreSQL gets an ephemeral
    // server via the pg-ephemeral gem's `run-env`; SQLite needs nothing extra.
    fn run_rails_verify(rails: RailsVersion, database: Database) -> RunResult {
        // Run everything from inside the example app. The PostgreSQL path
        // re-invokes this manager under `pg-ephemeral host run-env`, and that
        // child inherits this working directory, so both parent and child agree
        // on where the app lives (see rails_command).
        std::env::set_current_dir("rails_example")
            .expect("Failed to change into rails_example directory");

        let base_env = vec![
            ("RAILS_VERSION".to_string(), rails.requirement().to_string()),
            ("DB_ADAPTER".to_string(), database.adapter().to_string()),
            ("RAILS_ENV".to_string(), "test".to_string()),
        ];

        log::info!(
            "RailsVerify: bundle install (rails {})",
            rails.requirement()
        );
        if !Self::rails_command(&base_env, &["bundle", "install"]).success() {
            eprintln!("RailsVerify FAILED: bundle install failed");
            return RunResult::Failure;
        }

        match database {
            Database::Sqlite => Self::run_rails_verify_steps(&base_env),
            Database::Postgresql => Self::run_rails_verify_postgresql(&base_env),
        }
    }

    // `pg-ephemeral host run-env` boots a throwaway PostgreSQL and runs a single
    // host command with PG*/DATABASE_URL pointing at the container's published
    // port. The whole verification (schema load + two mutant runs) must share
    // one server, so we re-invoke this manager under run-env via the
    // `rails-verify-steps` subcommand; every child it spawns inherits the PG*
    // variables.
    fn run_rails_verify_postgresql(base_env: &[(String, String)]) -> RunResult {
        let manager = std::env::current_exe()
            .expect("Failed to determine manager executable path")
            .into_os_string()
            .into_string()
            .expect("Manager executable path is not valid UTF-8");

        let status = Self::rails_command(
            base_env,
            &[
                "bundle",
                "exec",
                "pg-ephemeral",
                "host",
                "run-env",
                "--",
                &manager,
                "ruby",
                "rails-verify-steps",
            ],
        );

        if status.success() {
            RunResult::Success
        } else {
            RunResult::Failure
        }
    }

    // Prepare the test database, then run mutant twice: once expecting the
    // boundary mutation to survive (no covering spec), once expecting 100%
    // coverage with it. Uses --jobs 2 so the worker-isolation hooks fork.
    fn run_rails_verify_steps(extra_env: &[(String, String)]) -> RunResult {
        let mut env = extra_env.to_vec();

        // `pg-ephemeral host run-env` exports a DATABASE_URL pointing at the
        // server's maintenance database. Point the app at a dedicated
        // `rails_example_test` instead, so the parallel-worker hooks have a
        // template database to clone. SQLite runs set no DATABASE_URL.
        if let Ok(url) = std::env::var("DATABASE_URL") {
            env.push((
                "DATABASE_URL".to_string(),
                Self::url_with_database(&url, "rails_example_test"),
            ));
        }
        let env = env.as_slice();

        log::info!("RailsVerify: preparing test database");
        if !Self::rails_command(env, &["bundle", "exec", "rails", "db:test:prepare"]).success() {
            eprintln!("RailsVerify FAILED: db:test:prepare failed");
            return RunResult::Failure;
        }

        let mutant = &[
            "bundle",
            "exec",
            "mutant",
            "run",
            "--jobs",
            "2",
            "User#adult?",
        ];

        log::info!("RailsVerify: running without covering spec (expecting survivors)");
        if Self::rails_command(env, mutant).success() {
            eprintln!("RailsVerify FAILED: expected surviving mutations without covering spec");
            return RunResult::Failure;
        }
        log::info!("RailsVerify: mutation survived as expected");

        log::info!("RailsVerify: running with covering spec (expecting 100% coverage)");
        let mut covering_env = env.to_vec();
        covering_env.push(("WITH_COVERING_SPEC".to_string(), "1".to_string()));
        if !Self::rails_command(&covering_env, mutant).success() {
            eprintln!("RailsVerify FAILED: expected 100% coverage with covering spec");
            return RunResult::Failure;
        }
        log::info!("RailsVerify: 100% coverage achieved as expected");

        RunResult::Success
    }

    // Runs in the current working directory, which is the rails_example app:
    // run_rails_verify chdir's into it, and the run-env child inherits that cwd.
    fn rails_command(env: &[(String, String)], args: &[&str]) -> process::ExitStatus {
        let mut command = process::Command::new(args[0]);
        command.args(&args[1..]);

        for (name, value) in env {
            command.env(name, value);
        }

        command
            .spawn()
            .expect("Failed to spawn process")
            .wait()
            .expect("Failed to wait for process")
    }

    // Replace the database name (the path segment after the last '/', before any
    // query string) in a `scheme://user:pass@host:port/database[?query]` URL.
    fn url_with_database(url: &str, database: &str) -> String {
        let (base, query) = match url.split_once('?') {
            Some((base, query)) => (base, Some(query)),
            None => (url, None),
        };

        let prefix = base.rsplit_once('/').map_or(base, |(prefix, _)| prefix);

        match query {
            Some(query) => format!("{prefix}/{database}?{query}"),
            None => format!("{prefix}/{database}"),
        }
    }

    fn run_host(self, command: Command, rerun_config: RerunConfig) -> RunResult {
        let config = Self::build_command_config(command);
        if config.arguments.is_empty() {
            return RunResult::Success;
        }

        rerun_config.execute(move |capture| Self::spawn_host_process(&config, capture))
    }

    fn spawn_host_process(config: &CommandConfig, capture: bool) -> process::Child {
        let mut command = process::Command::new(&config.arguments[0]);
        command
            .args(&config.arguments[1..])
            .current_dir(config.working_dir);

        if capture {
            command
                .stdout(process::Stdio::piped())
                .stderr(process::Stdio::piped());
        }

        command.spawn().expect("Failed to spawn process")
    }

    fn run_container(self, base_image: &'static str, command: Command) -> RunResult {
        let runtime = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .expect("Failed to create tokio runtime");

        runtime.block_on(self.run_container_async(base_image, command))
    }

    async fn run_container_async(self, base_image: &str, command: Command) -> RunResult {
        let backend = ociman::backend::resolve::auto()
            .await
            .unwrap_or_else(|error| {
                panic!("Failed to resolve container backend: {}", error);
            });

        let image = self.ensure_image(&backend, base_image).await;
        let config = Self::build_command_config(command);

        if config.arguments.is_empty() {
            return RunResult::Success;
        }

        let current_directory = env::current_dir().unwrap_or_else(|error| {
            panic!("Failed to get current directory: {}", error);
        });

        let source_path = current_directory.join(config.working_dir);
        let mount_spec = format!("type=bind,source={},target=/app", source_path.display());

        let bundle_path: cmd_proc::EnvVariableName = "BUNDLE_PATH".parse().unwrap();

        let result = ociman::Definition::new(backend.clone(), image.clone())
            .mount(mount_spec)
            .workdir("/app")
            .environment_variable(bundle_path, "/app/vendor/bundle")
            .remove()
            .arguments(config.arguments.iter().cloned())
            .run()
            .await;

        match result {
            Ok(()) => RunResult::Success,
            Err(error) => {
                eprintln!("Container execution failed: {}", error);
                RunResult::Failure
            }
        }
    }

    async fn ensure_image(&self, backend: &ociman::Backend, base_image: &str) -> ociman::Reference {
        let dockerfile = format!(
            "FROM {}\nRUN apk add --no-cache git build-base yaml-dev\n",
            base_image
        );

        let name: ociman::reference::Name = "mutant-ruby".parse().unwrap();

        let build_definition =
            ociman::BuildDefinition::from_instructions_hash(backend, name, &dockerfile);

        build_definition.build_if_absent().await
    }

    fn build_command_config(command: Command) -> CommandConfig {
        match command {
            Command::Prepare => CommandConfig::ruby(vec![]),
            Command::Exec { arguments } => {
                let mut result = vec!["ruby".to_string()];
                result.extend(arguments);
                CommandConfig::ruby(result)
            }
            Command::Bundle { arguments } => {
                let mut result = vec!["bundle".to_string()];
                result.extend(arguments);
                CommandConfig::ruby(result)
            }
            Command::Rspec { action } => match action {
                rspec::Command::Unit { arguments } => {
                    CommandConfig::ruby(bundle_exec_arguments(&["rspec", "spec/unit"], &arguments))
                }
                rspec::Command::Integration { action, arguments } => match action {
                    None => CommandConfig::ruby(bundle_exec_arguments(
                        &["rspec", "spec/integration"],
                        &arguments,
                    )),
                    Some(rspec::integration::Command::Misc { arguments }) => {
                        CommandConfig::ruby(bundle_exec_arguments(
                            &[
                                "rspec",
                                "spec/integration/mutant/null_spec.rb",
                                "spec/integration/mutant/isolation/fork_spec.rb",
                                "spec/integration/mutant/test_mutator_handles_types_spec.rb",
                                "spec/integration/mutant/parallel_spec.rb",
                            ],
                            &arguments,
                        ))
                    }
                    Some(rspec::integration::Command::Minitest { arguments }) => {
                        CommandConfig::ruby(bundle_exec_arguments(
                            &["rspec", "spec/integration", "-e", "minitest"],
                            &arguments,
                        ))
                    }
                    Some(rspec::integration::Command::Rspec { arguments }) => {
                        CommandConfig::ruby(bundle_exec_arguments(
                            &["rspec", "spec/integration", "-e", "rspec"],
                            &arguments,
                        ))
                    }
                    Some(rspec::integration::Command::Generation { arguments }) => {
                        CommandConfig::ruby(bundle_exec_arguments(
                            &["rspec", "spec/integration", "-e", "generation"],
                            &arguments,
                        ))
                    }
                },
            },
            Command::Mutant { action } => match action {
                mutant::Command::Test { arguments } => CommandConfig::ruby(bundle_exec_arguments(
                    &["mutant", "test", "spec/unit"],
                    &arguments,
                )),
                mutant::Command::Run { arguments } => {
                    CommandConfig::ruby(bundle_exec_arguments(&["mutant", "run"], &arguments))
                }
            },
            Command::Rubocop { arguments } => {
                CommandConfig::ruby(bundle_exec_arguments(&["rubocop"], &arguments))
            }
            Command::QuickStartVerify => {
                unreachable!("QuickStartVerify is handled separately in run()")
            }
            Command::RailsVerify { .. } => {
                unreachable!("RailsVerify is handled separately in run()")
            }
            Command::RailsVerifySteps => {
                unreachable!("RailsVerifySteps is handled separately in run()")
            }
        }
    }
}

fn bundle_exec_arguments(base_arguments: &[&str], extra_arguments: &[String]) -> Vec<String> {
    let mut arguments = vec!["bundle".to_string(), "exec".to_string()];
    arguments.extend(base_arguments.iter().map(|s| s.to_string()));
    arguments.extend(extra_arguments.iter().cloned());
    arguments
}

struct CommandConfig {
    working_dir: &'static str,
    arguments: Vec<String>,
}

impl CommandConfig {
    fn ruby(arguments: Vec<String>) -> Self {
        Self {
            working_dir: "ruby",
            arguments,
        }
    }
}
