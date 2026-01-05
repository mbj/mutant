use clap::{Subcommand, ValueEnum};
use std::env;
use std::process;

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
    pub fn run(self, runtime: Runtime) -> RunResult {
        runtime.run(self)
    }
}

impl Runtime {
    pub fn run(self, command: Command) -> RunResult {
        match self {
            Self::Host => self.run_host(command),
            Self::Ruby32 => self.run_container("docker.io/library/ruby:3.2-alpine", command),
            Self::Ruby33 => self.run_container("docker.io/library/ruby:3.3-alpine", command),
            Self::Ruby34 => self.run_container("docker.io/library/ruby:3.4-alpine", command),
            Self::Ruby40 => self.run_container("docker.io/library/ruby:4.0-alpine", command),
        }
    }

    fn run_host(self, command: Command) -> RunResult {
        let arguments = Self::build_arguments(command);
        if arguments.is_empty() {
            return RunResult::Success;
        }

        let status = process::Command::new(&arguments[0])
            .args(&arguments[1..])
            .current_dir("ruby")
            .status()
            .expect("Failed to execute process");

        if status.success() {
            RunResult::Success
        } else {
            RunResult::Failure
        }
    }

    fn run_container(self, base_image: &'static str, command: Command) -> RunResult {
        let backend = ociman::backend::resolve::auto().unwrap_or_else(|error| {
            panic!("Failed to resolve container backend: {}", error);
        });

        let image = self.ensure_image(&backend, base_image);
        let arguments = Self::build_arguments(command);

        if arguments.is_empty() {
            return RunResult::Success;
        }

        let current_directory = env::current_dir().unwrap_or_else(|error| {
            panic!("Failed to get current directory: {}", error);
        });

        let ruby_path = current_directory.join("ruby");
        let mount_spec = format!("type=bind,source={},target=/app", ruby_path.display());

        let result = ociman::Definition::new(backend.clone(), image.clone())
            .mount(mount_spec)
            .workdir("/app")
            .environment_variable("BUNDLE_PATH", "/app/vendor/bundle")
            .remove()
            .arguments(arguments.iter().cloned())
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

    fn build_arguments(command: Command) -> Vec<String> {
        match command {
            Command::Prepare => vec![],
            Command::Exec { arguments } => {
                let mut result = vec!["ruby".to_string()];
                result.extend(arguments);
                result
            }
            Command::Bundle { arguments } => {
                let mut result = vec!["bundle".to_string()];
                result.extend(arguments);
                result
            }
            Command::Rspec { action } => match action {
                rspec::Command::Unit { arguments } => {
                    bundle_exec_arguments(&["rspec", "spec/unit"], &arguments)
                }
                rspec::Command::Integration { action, arguments } => match action {
                    None => bundle_exec_arguments(&["rspec", "spec/integration"], &arguments),
                    Some(rspec::integration::Command::Misc { arguments }) => bundle_exec_arguments(
                        &[
                            "rspec",
                            "spec/integration/mutant/null_spec.rb",
                            "spec/integration/mutant/isolation/fork_spec.rb",
                            "spec/integration/mutant/test_mutator_handles_types_spec.rb",
                            "spec/integration/mutant/parallel_spec.rb",
                        ],
                        &arguments,
                    ),
                    Some(rspec::integration::Command::Minitest { arguments }) => {
                        bundle_exec_arguments(
                            &["rspec", "spec/integration", "-e", "minitest"],
                            &arguments,
                        )
                    }
                    Some(rspec::integration::Command::Rspec { arguments }) => {
                        bundle_exec_arguments(
                            &["rspec", "spec/integration", "-e", "rspec"],
                            &arguments,
                        )
                    }
                    Some(rspec::integration::Command::Generation { arguments }) => {
                        bundle_exec_arguments(
                            &["rspec", "spec/integration", "-e", "generation"],
                            &arguments,
                        )
                    }
                },
            },
            Command::Mutant { action } => match action {
                mutant::Command::Test { arguments } => {
                    bundle_exec_arguments(&["mutant", "test", "spec/unit"], &arguments)
                }
                mutant::Command::Run { arguments } => {
                    bundle_exec_arguments(&["mutant", "run"], &arguments)
                }
            },
            Command::Rubocop { arguments } => bundle_exec_arguments(&["rubocop"], &arguments),
        }
    }
}

fn bundle_exec_arguments(base_arguments: &[&str], extra_arguments: &[String]) -> Vec<String> {
    let mut arguments = vec!["bundle".to_string(), "exec".to_string()];
    arguments.extend(base_arguments.iter().map(|s| s.to_string()));
    arguments.extend(extra_arguments.iter().cloned());
    arguments
}
