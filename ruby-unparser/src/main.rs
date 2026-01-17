use std::io::{self, Read};
use std::process::ExitCode;

fn main() -> ExitCode {
    let mut source = String::new();
    if let Err(error) = io::stdin().read_to_string(&mut source) {
        eprintln!("Error reading input: {}", error);
        return ExitCode::FAILURE;
    }

    match ruby_unparser::unparse(&source) {
        Ok(output) => {
            print!("{}", output);
            ExitCode::SUCCESS
        }
        Err(error) => {
            eprintln!("{}", error);
            ExitCode::FAILURE
        }
    }
}
