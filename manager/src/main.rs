use clap::{Parser, Subcommand};
use std::fs;
use std::num::NonZeroU32;

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

        /// Run command multiple times
        #[arg(long)]
        rerun: Option<NonZeroU32>,

        /// Concurrency for reruns (defaults to number of CPUs)
        #[arg(long)]
        jobs: Option<NonZeroU32>,

        #[command(subcommand)]
        action: ruby::Command,
    },
}

fn main() -> ruby::RunResult {
    let cli = Cli::parse();

    match cli.command {
        Commands::Ruby {
            ruby_runtime,
            rerun,
            jobs,
            action,
        } => {
            prepare();

            let runs = rerun.map(|n| n.get()).unwrap_or(1);

            let jobs = jobs.map(|n| n.get()).unwrap_or_else(|| {
                std::thread::available_parallelism()
                    .map(|parallelism| parallelism.get() as u32)
                    .unwrap_or_else(|_| {
                        log::warn!("Could not determine CPU count, defaulting to 1 job");
                        1
                    })
            });

            let rerun_config = ruby::RerunConfig { runs, jobs };
            action.run(ruby_runtime, rerun_config)
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
