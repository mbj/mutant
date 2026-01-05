use clap::{Parser, Subcommand};
use std::fs;

mod ruby;

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
        #[arg(long, default_value = "host")]
        ruby_runtime: ruby::Runtime,

        #[command(subcommand)]
        action: ruby::Command,
    },
}

fn main() -> ruby::RunResult {
    let cli = Cli::parse();

    match cli.command {
        Commands::Ruby {
            ruby_runtime,
            action,
        } => {
            prepare();
            action.run(ruby_runtime)
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
