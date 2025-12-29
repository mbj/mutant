use clap::{Parser, Subcommand};
use std::fs;
use std::os::unix::process::CommandExt;
use std::process::Command;

#[derive(Parser)]
#[command(name = "manager")]
#[command(about = "Mutant development manager")]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
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
enum Rspec {
    /// Run unit specs
    Unit {
        /// Additional arguments
        arguments: Vec<String>,
    },
    /// Run integration specs
    Integration {
        #[command(subcommand)]
        action: Option<Integration>,
        /// Additional arguments (only when running all integration tests)
        #[arg(trailing_var_arg = true)]
        arguments: Vec<String>,
    },
}

#[derive(Subcommand)]
enum Integration {
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
        Commands::Ruby { action } => {
            prepare();
            match action {
                Ruby::Prepare => {}
                Ruby::Exec { arguments } => ruby_exec(&arguments),
                Ruby::Bundle { arguments } => bundle_run(&arguments),
                Ruby::Rspec { action } => match action {
                    Rspec::Unit { arguments } => {
                        bundle_exec_with_args(&["rspec", "spec/unit"], &arguments)
                    }
                    Rspec::Integration { action, arguments } => match action {
                        None => bundle_exec_with_args(&["rspec", "spec/integration"], &arguments),
                        Some(Integration::Misc { arguments }) => bundle_exec_with_args(
                            &[
                                "rspec",
                                "spec/integration/mutant/null_spec.rb",
                                "spec/integration/mutant/isolation/fork_spec.rb",
                                "spec/integration/mutant/test_mutator_handles_types_spec.rb",
                                "spec/integration/mutant/parallel_spec.rb",
                            ],
                            &arguments,
                        ),
                        Some(Integration::Minitest { arguments }) => bundle_exec_with_args(
                            &["rspec", "spec/integration", "-e", "minitest"],
                            &arguments,
                        ),
                        Some(Integration::Rspec { arguments }) => bundle_exec_with_args(
                            &["rspec", "spec/integration", "-e", "rspec"],
                            &arguments,
                        ),
                        Some(Integration::Generation { arguments }) => bundle_exec_with_args(
                            &["rspec", "spec/integration", "-e", "generation"],
                            &arguments,
                        ),
                    },
                },
                Ruby::Mutant { action } => match action {
                    Mutant::Test { arguments } => {
                        bundle_exec_with_args(&["mutant", "test", "spec/unit"], &arguments)
                    }
                    Mutant::Run { arguments } => {
                        bundle_exec_with_args(&["mutant", "run"], &arguments)
                    }
                },
                Ruby::Rubocop { arguments } => bundle_exec_with_args(&["rubocop"], &arguments),
            }
        }
    }
}

fn prepare() {
    fs::write("ruby/VERSION", format!("{}\n", env!("CARGO_PKG_VERSION"))).unwrap_or_else(|error| {
        panic!("Failed to write ruby/VERSION: {}", error);
    });

    fs::copy("LICENSE", "ruby/LICENSE").unwrap_or_else(|error| {
        panic!("Failed to copy LICENSE to ruby/LICENSE: {}", error);
    });
}

fn ruby_exec(arguments: &[String]) {
    let error = Command::new("ruby")
        .args(arguments)
        .current_dir("ruby")
        .exec();

    panic!("Failed to execute ruby: {}", error);
}

fn bundle_run(arguments: &[String]) {
    let error = Command::new("bundle")
        .args(arguments)
        .current_dir("ruby")
        .exec();

    panic!("Failed to execute bundle: {}", error);
}

fn bundle_exec_with_args(base_args: &[&str], extra_args: &[String]) {
    let mut args: Vec<&str> = base_args.to_vec();
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
