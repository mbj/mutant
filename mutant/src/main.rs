use clap::Parser;
use clap::Subcommand;
use log::warn;
use std::env;
use std::os::unix::process::CommandExt;
use std::process::Command;

mod ipc;

#[derive(Parser)]
#[command(name = "mutant")]
#[command(about = "Mutation testing engine")]
#[command(disable_help_subcommand = true)]
struct Cli {
    #[command(subcommand)]
    command: CliCommand,
}

#[derive(Subcommand)]
enum CliCommand {
    /// IPC commands
    Ipc {
        #[command(subcommand)]
        command: ipc::Command,
    },

    #[command(external_subcommand)]
    External(Vec<String>),
}

fn main() {
    env_logger::init();

    match Cli::parse().command {
        CliCommand::Ipc { command } => match command {
            ipc::Command::Test(test) => test.run(),
        },
        CliCommand::External(arguments) => {
            warn!(
                "Rust wrapper did not handle this command yet, delegating to Ruby implementation"
            );
            exec_ruby_mutant(&arguments);
        }
    }
}

fn exec_ruby_mutant(arguments: &[String]) {
    env::set_current_dir("ruby").unwrap_or_else(|error| {
        panic!("Failed to change to ruby directory: {}", error);
    });

    let error = Command::new("bundle")
        .arg("exec")
        .arg("mutant-ruby")
        .args(arguments)
        .exec();

    panic!("Failed to execute Ruby mutant: {}", error);
}
