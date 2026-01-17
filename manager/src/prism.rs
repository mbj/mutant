use crate::ruby::RunResult;
use clap::Subcommand;
use std::ffi::OsStr;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Subcommand)]
pub enum CommandKind {
    /// Generate config.json from the latest Prism release tag.
    Config {
        /// Output path for the generated config.json
        #[arg(long, default_value = "ruby-unparser/prism/config.json")]
        output: PathBuf,
    },
}

pub fn run(command: CommandKind) -> RunResult {
    match command {
        CommandKind::Config { output } => match generate_config(&output) {
            Ok(()) => RunResult::Success,
            Err(message) => {
                log::error!("{message}");
                RunResult::Failure
            }
        },
    }
}

fn generate_config(output: &Path) -> Result<(), String> {
    let temp_dir = TempDir::new("prism-checkout")?;
    let checkout_path = temp_dir.path();

    run_command(
        Command::new("git")
            .arg("clone")
            .arg("--quiet")
            .arg("https://github.com/ruby/prism")
            .arg(checkout_path),
    )?;

    let tag = latest_release_tag(checkout_path)?;

    run_command(
        Command::new("git")
            .arg("checkout")
            .arg("--quiet")
            .arg(&tag)
            .current_dir(checkout_path),
    )?;

    let config_yml = checkout_path.join("config.yml");
    let config_json = read_yaml_as_json(&config_yml)?;

    if let Some(parent) = output.parent() {
        fs::create_dir_all(parent).map_err(|error| {
            format!(
                "Failed to create output directory {}: {error}",
                parent.display()
            )
        })?;
    }

    fs::write(output, config_json).map_err(|error| {
        format!(
            "Failed to write config.json to {}: {error}",
            output.display()
        )
    })?;

    log::info!(
        "Generated config.json from tag {} at {}",
        tag,
        output.display()
    );

    Ok(())
}

fn latest_release_tag(repo_dir: &Path) -> Result<String, String> {
    let output = Command::new("git")
        .arg("tag")
        .arg("--list")
        .arg("--sort=-v:refname")
        .current_dir(repo_dir)
        .output()
        .map_err(|error| format!("Failed to list Prism tags: {error}"))?;

    if !output.status.success() {
        return Err(format!(
            "Failed to list Prism tags: {}",
            String::from_utf8_lossy(&output.stderr)
        ));
    }

    let mut lines = String::from_utf8_lossy(&output.stdout).lines();
    let tag = lines
        .next()
        .ok_or_else(|| "No tags found in Prism repository".to_string())?;

    Ok(tag.to_string())
}

fn read_yaml_as_json(path: &Path) -> Result<Vec<u8>, String> {
    let file = fs::File::open(path)
        .map_err(|error| format!("Failed to open {}: {error}", path.display()))?;

    let yaml_value: serde_yaml::Value =
        serde_yaml::from_reader(file).map_err(|error| {
            format!("Failed to parse YAML from {}: {error}", path.display())
        })?;

    let mut out = Vec::new();
    serde_json::to_writer(&mut out, &yaml_value)
        .map_err(|error| format!("Failed to serialize JSON: {error}"))?;

    Ok(out)
}

fn run_command(mut command: Command) -> Result<(), String> {
    let status = command
        .status()
        .map_err(|error| format!("Failed to run {:?}: {error}", command_display(command)))?;

    if status.success() {
        Ok(())
    } else {
        Err(format!(
            "Command failed: {:?}",
            command_display(command)
        ))
    }
}

fn command_display(command: &Command) -> Vec<String> {
    let mut parts = Vec::new();
    parts.push(command.get_program().to_string_lossy().to_string());
    parts.extend(command.get_args().map(os_to_string));
    parts
}

fn os_to_string(value: &OsStr) -> String {
    value.to_string_lossy().to_string()
}

struct TempDir {
    path: PathBuf,
}

impl TempDir {
    fn new(prefix: &str) -> Result<Self, String> {
        let nanos = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .map_err(|error| format!("Failed to read system time: {error}"))?
            .as_nanos();
        let mut path = std::env::temp_dir();
        path.push(format!("{prefix}-{}-{}", std::process::id(), nanos));
        fs::create_dir_all(&path)
            .map_err(|error| format!("Failed to create temp dir {}: {error}", path.display()))?;
        Ok(Self { path })
    }

    fn path(&self) -> &Path {
        &self.path
    }
}

impl Drop for TempDir {
    fn drop(&mut self) {
        let _ = fs::remove_dir_all(&self.path);
    }
}
