use log::warn;
use std::env;
use std::os::unix::process::CommandExt;
use std::process::Command;

fn main() {
    env_logger::Builder::from_default_env()
        .filter_level(log::LevelFilter::Warn)
        .init();

    let args: Vec<String> = env::args().collect();

    // For now, always delegate to Ruby with a warning
    warn!("Rust wrapper did not handle this command yet, delegating to Ruby implementation");

    exec_ruby_mutant(&args[1..]);
}

fn exec_ruby_mutant(args: &[String]) {
    env::set_current_dir("ruby").unwrap_or_else(|error| {
        panic!("Failed to change to ruby directory: {}", error);
    });

    let error = Command::new("bundle")
        .arg("exec")
        .arg("mutant")
        .args(args)
        .exec();

    panic!("Failed to execute Ruby mutant: {}", error);
}
