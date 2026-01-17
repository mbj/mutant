use clap::{Parser, Subcommand};
use std::fs;
use std::num::NonZeroU32;

mod ruby;

#[derive(Parser)]
#[command(name = "manager")]
#[command(about = "Mutant development manager")]
struct Cli {
    #[command(subcommand)]
    command: Command,
}

#[derive(Subcommand)]
enum Command {
    /// Build and push all gems to rubygems.org
    Release,
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
        command: ruby::Command,
    },
}

fn main() -> ruby::RunResult {
    let cli = Cli::parse();

    match cli.command {
        Command::Release => {
            prepare();
            release()
        }
        Command::Ruby {
            ruby_runtime,
            rerun,
            jobs,
            command,
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
            command.run(ruby_runtime, rerun_config)
        }
    }
}

fn release() -> ruby::RunResult {
    const GEMSPECS: &[&str] = &[
        "mutant.gemspec",
        "mutant-rspec.gemspec",
        "mutant-minitest.gemspec",
    ];

    for gemspec in GEMSPECS {
        if !gem_build(gemspec) {
            return ruby::RunResult::Failure;
        }
        if !gem_push(gemspec) {
            return ruby::RunResult::Failure;
        }
    }

    ruby::RunResult::Success
}

fn gem_build(gemspec: &str) -> bool {
    log::info!("Building {}", gemspec);
    std::process::Command::new("gem")
        .args(["build", gemspec])
        .current_dir("ruby")
        .status()
        .expect("Failed to run gem build")
        .success()
}

fn gem_push(gemspec: &str) -> bool {
    let gem_file = gemspec.replace(".gemspec", &format!("-{}.gem", env!("CARGO_PKG_VERSION")));
    log::info!("Pushing {}", gem_file);
    std::process::Command::new("gem")
        .args(["push", &gem_file])
        .current_dir("ruby")
        .status()
        .expect("Failed to run gem push")
        .success()
}

fn prepare() {
    fs::write("ruby/VERSION", format!("{}\n", env!("CARGO_PKG_VERSION"))).unwrap_or_else(|error| {
        panic!("Failed to write ruby/VERSION: {}", error);
    });

    fs::copy("LICENSE", "ruby/LICENSE").unwrap_or_else(|error| {
        panic!("Failed to copy LICENSE to ruby/LICENSE: {}", error);
    });
}
