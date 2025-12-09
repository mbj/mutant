use log::warn;
use std::env;
use std::os::unix::process::CommandExt;
use std::process::Command;

fn main() {
    env_logger::Builder::from_default_env()
        .filter_level(log::LevelFilter::Warn)
        .init();

    let arguments: Vec<String> = env::args().collect();

    // For now, always delegate to Ruby with a warning
    warn!("Rust wrapper did not handle this command yet, delegating to Ruby implementation");

    exec_ruby_mutant(&arguments[1..]);
}

fn exec_ruby_mutant(arguments: &[String]) {
    env::set_current_dir("ruby").unwrap_or_else(|error| {
        panic!("Failed to change to ruby directory: {}", error);
    });

    let error = Command::new("bundle")
        .arg("exec")
        .arg("mutant")
        .args(arguments)
        .env("MUTANT_RUST", "1")
        .env("MUTANT_VERSION", env!("CARGO_PKG_VERSION"))
        .exec();

    panic!("Failed to execute Ruby mutant: {}", error);
}
