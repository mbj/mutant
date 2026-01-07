mod test;

use serde::Serialize;
use serde::Serializer;
use serde::de::DeserializeOwned;
use serde::ser::SerializeMap;
use std::env;
use std::io;
use std::io::Read;
use std::io::Write;
use std::os::unix::net::UnixListener;
use std::os::unix::net::UnixStream;
use std::path::PathBuf;
use std::process::Child;
use std::process::Stdio;
use std::time::SystemTime;
use std::time::UNIX_EPOCH;
use uuid::Uuid;

#[derive(clap::Subcommand)]
pub enum Command {
    /// Test IPC connection
    Test(test::Command),
}

pub trait Request: Serialize {
    type Response: DeserializeOwned;
}

pub struct Ping {
    pub payload: String,
}

impl Ping {
    pub fn new() -> Self {
        Self {
            payload: Uuid::new_v4().to_string(),
        }
    }
}

impl Serialize for Ping {
    fn serialize<S: Serializer>(&self, serializer: S) -> Result<S::Ok, S::Error> {
        let mut map = serializer.serialize_map(Some(2))?;
        map.serialize_entry("type", "ping")?;
        map.serialize_entry("payload", &self.payload)?;
        map.end()
    }
}

impl Request for Ping {
    type Response = String;
}

pub struct Exit;

impl Serialize for Exit {
    fn serialize<S: Serializer>(&self, serializer: S) -> Result<S::Ok, S::Error> {
        let mut map = serializer.serialize_map(Some(1))?;
        map.serialize_entry("type", "exit")?;
        map.end()
    }
}

impl Request for Exit {
    type Response = ();
}

pub struct Connection {
    stream: UnixStream,
}

impl Connection {
    pub fn new(stream: UnixStream) -> Self {
        Self { stream }
    }

    pub fn call<R: Request>(&mut self, request: &R) -> io::Result<R::Response> {
        self.send(request)?;
        self.receive()
    }

    pub fn expect_close(&mut self) -> io::Result<()> {
        let mut buffer = [0u8; 1];
        match self.stream.read(&mut buffer)? {
            0 => Ok(()),
            _ => Err(io::Error::new(
                io::ErrorKind::InvalidData,
                "Expected connection to be closed",
            )),
        }
    }

    fn send<R: Request>(&mut self, request: &R) -> io::Result<()> {
        let body = serde_json::to_vec(request)?;
        let length = body.len() as u32;
        self.stream.write_all(&length.to_le_bytes())?;
        self.stream.write_all(&body)?;
        self.stream.flush()
    }

    fn receive<T: DeserializeOwned>(&mut self) -> io::Result<T> {
        let mut header = [0u8; 4];
        self.stream.read_exact(&mut header)?;
        let length = u32::from_le_bytes(header) as usize;

        let mut body = vec![0u8; length];
        self.stream.read_exact(&mut body)?;

        serde_json::from_slice(&body)
            .map_err(|error| io::Error::new(io::ErrorKind::InvalidData, error))
    }
}

pub fn socket_path() -> PathBuf {
    let timestamp = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();
    let pid = std::process::id();

    env::temp_dir().join(format!("mutant-{timestamp}-{pid}.sock"))
}

pub struct Server {
    listener: UnixListener,
    path: PathBuf,
}

impl Server {
    pub fn new() -> io::Result<Self> {
        let path = socket_path();

        if path.exists() {
            std::fs::remove_file(&path)?;
        }

        let listener = UnixListener::bind(&path)?;

        Ok(Self { listener, path })
    }

    pub fn path(&self) -> &PathBuf {
        &self.path
    }

    pub fn accept(&self) -> io::Result<Connection> {
        let (stream, _address) = self.listener.accept()?;
        Ok(Connection::new(stream))
    }

    pub fn spawn_ruby(&self) -> io::Result<Child> {
        std::process::Command::new("bundle")
            .arg("exec")
            .arg("mutant-ruby")
            .arg("ipc")
            .arg("--socket")
            .arg(&self.path)
            .current_dir("ruby")
            .stdin(Stdio::null())
            .stdout(Stdio::inherit())
            .stderr(Stdio::inherit())
            .spawn()
    }
}

impl Drop for Server {
    fn drop(&mut self) {
        let _ = std::fs::remove_file(&self.path);
    }
}
