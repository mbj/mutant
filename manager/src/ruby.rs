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
    #[value(name = "container-3.2")]
    Ruby32,
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
            _ => match self {
                Self::Host => self.run_host(command, rerun_config),
                Self::Ruby32 => self.run_container("docker.io/library/ruby:3.2-alpine", command),
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
        log::info!("QuickStartVerify: Running without covering spec (expecting mutations to survive)");
        let status_without = self.run_quick_start_command(mutant_args, false);
        if status_without.success() {
            eprintln!("QuickStartVerify FAILED: Expected mutations to survive without covering spec");
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

    fn run_quick_start_command(&self, args: &[&str], with_covering_spec: bool) -> process::ExitStatus {
        let mut command = process::Command::new("bundle");
        command
            .arg("exec")
            .args(args)
            .current_dir("quick_start");

        if with_covering_spec {
            command.env("WITH_COVERING_SPEC", "1");
        }

        let mut child = command.spawn().expect("Failed to spawn process");
        child.wait().expect("Failed to wait for process")
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
        let backend = ociman::backend::resolve::auto().unwrap_or_else(|error| {
            panic!("Failed to resolve container backend: {}", error);
        });

        let image = self.ensure_image(&backend, base_image);
        let config = Self::build_command_config(command);

        if config.arguments.is_empty() {
            return RunResult::Success;
        }

        let current_directory = env::current_dir().unwrap_or_else(|error| {
            panic!("Failed to get current directory: {}", error);
        });

        let source_path = current_directory.join(config.working_dir);
        let mount_spec = format!("type=bind,source={},target=/app", source_path.display());

        let result = ociman::Definition::new(backend.clone(), image.clone())
            .mount(mount_spec)
            .workdir("/app")
            .environment_variable("BUNDLE_PATH", "/app/vendor/bundle")
            .remove()
            .arguments(config.arguments.iter().cloned())
            .run();

        match result {
            Ok(()) => RunResult::Success,
            Err(error) => {
                eprintln!("Container execution failed: {}", error);
                RunResult::Failure
            }
        }
    }

    fn ensure_image(&self, backend: &ociman::Backend, base_image: &str) -> ociman::Reference {
        let dockerfile = format!(
            "FROM {}\nRUN apk add --no-cache git build-base yaml-dev\n",
            base_image
        );

        let name: ociman::reference::Name = "mutant-ruby".parse().unwrap();

        let build_definition =
            ociman::BuildDefinition::from_instructions_hash(backend, name, &dockerfile);

        build_definition.build_if_absent()
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
