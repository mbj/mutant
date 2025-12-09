use clap::{Parser, Subcommand};
use std::fs;
use std::os::unix::process::CommandExt;
use std::process::Command;

mod check;
mod tasks;

#[derive(Parser)]
#[command(name = "manager")]
#[command(about = "Mutant development manager")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Run all checks in parallel with TUI
    Check,
    /// Execute commands in Ruby environment
    Ruby {
        #[command(subcommand)]
        action: Ruby,
    },
}

#[derive(Subcommand)]
enum Ruby {
    /// Prepare ruby directory (VERSION and LICENSE files)
    Prepare,
    /// Execute a command
    Exec {
        /// Command and arguments to execute
        arguments: Vec<String>,
    },
    /// Run rspec commands
    Rspec {
        #[command(subcommand)]
        action: Rspec,
    },
    /// Run mutant commands
    Mutant {
        #[command(subcommand)]
        action: Mutant,
    },
    /// Run rubocop
    Rubocop {
        /// Additional arguments
        arguments: Vec<String>,
    },
}

#[derive(Subcommand)]
#[allow(clippy::enum_variant_names)]
enum Rspec {
    /// Run unit specs
    SpecUnit {
        /// Additional arguments
        arguments: Vec<String>,
    },
    /// Run integration misc specs
    IntegrationMisc {
        /// Additional arguments
        arguments: Vec<String>,
    },
    /// Run integration minitest specs
    IntegrationMinitest {
        /// Additional arguments
        arguments: Vec<String>,
    },
    /// Run integration rspec specs
    IntegrationRspec {
        /// Additional arguments
        arguments: Vec<String>,
    },
    /// Run integration generation specs
    IntegrationGeneration {
        /// Additional arguments
        arguments: Vec<String>,
    },
}

#[derive(Subcommand)]
enum Mutant {
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

fn main() {
    let cli = Cli::parse();

    match cli.command {
        Commands::Check => check::run(),
        Commands::Ruby { action } => {
            prepare();
            match action {
                Ruby::Prepare => {}
                Ruby::Exec { arguments } => bundle_exec(&arguments),
                Ruby::Rspec { action } => match action {
                    Rspec::SpecUnit { arguments } => run_task(&tasks::RSPEC_SPEC_UNIT, &arguments),
                    Rspec::IntegrationMisc { arguments } => {
                        run_task(&tasks::RSPEC_INTEGRATION_MISC, &arguments)
                    }
                    Rspec::IntegrationMinitest { arguments } => {
                        run_task(&tasks::RSPEC_INTEGRATION_MINITEST, &arguments)
                    }
                    Rspec::IntegrationRspec { arguments } => {
                        run_task(&tasks::RSPEC_INTEGRATION_RSPEC, &arguments)
                    }
                    Rspec::IntegrationGeneration { arguments } => {
                        run_task(&tasks::RSPEC_INTEGRATION_GENERATION, &arguments)
                    }
                },
                Ruby::Mutant { action } => match action {
                    Mutant::Test { arguments } => run_task(&tasks::MUTANT_TEST, &arguments),
                    Mutant::Run { arguments } => run_task(&tasks::MUTANT_RUN, &arguments),
                },
                Ruby::Rubocop { arguments } => run_task(&tasks::RUBOCOP, &arguments),
            }
        }
    }
}

pub fn prepare() {
    fs::write("ruby/VERSION", format!("{}\n", env!("CARGO_PKG_VERSION"))).unwrap_or_else(|error| {
        panic!("Failed to write ruby/VERSION: {}", error);
    });

    fs::copy("LICENSE", "ruby/LICENSE").unwrap_or_else(|error| {
        panic!("Failed to copy LICENSE to ruby/LICENSE: {}", error);
    });
}

fn run_task(task: &tasks::Task, extra_args: &[String]) {
    let mut args: Vec<&str> = task.args.to_vec();
    args.extend(extra_args.iter().map(|s| s.as_str()));
    bundle_exec(&args)
}

fn bundle_exec<S: AsRef<str>>(arguments: &[S]) {
    let args: Vec<&str> = arguments.iter().map(|s| s.as_ref()).collect();

    let error = Command::new("bundle")
        .arg("exec")
        .args(&args)
        .current_dir("ruby")
        .exec();

    panic!("Failed to execute command: {}", error);
}
