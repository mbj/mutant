use log::info;

use crate::ipc;

#[derive(clap::Parser)]
pub struct Command;

impl Command {
    pub fn run(self) {
        let server = ipc::Server::new().expect("Failed to create IPC server");
        info!("IPC server listening on {:?}", server.path());

        let mut child = server.spawn_ruby().expect("Failed to spawn Ruby");
        info!("Spawned Ruby process");

        let mut connection = server.accept().expect("Failed to accept connection");
        info!("Ruby connected");

        let ping = ipc::Ping::new();
        let response = connection.call(&ping).expect("Ping failed");
        assert_eq!(response, ping.payload, "Ping payload mismatch");
        info!("Ping successful, payload: {}", response);

        connection.call(&ipc::Exit).expect("Exit failed");
        info!("Exit sent");

        connection
            .expect_close()
            .expect("Ruby did not close connection");
        info!("Ruby closed connection");

        child.wait().expect("Failed to wait for Ruby");
        info!("IPC test complete");
    }
}
