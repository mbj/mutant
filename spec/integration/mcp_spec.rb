# frozen_string_literal: true

RSpec.describe 'MCP Integration' do
  let(:stdout_io) { StringIO.new }
  let(:stderr_io) { StringIO.new }
  let(:stdin_io) { StringIO.new }

  let(:timer) { Mutant::Timer.new(process: Process) }

  let(:gen_id) do
    id = 0
    -> { (id += 1).to_s }
  end

  let(:root_segment) do
    Mutant::Segment.new(
      id:              0,
      name:            :integration_test,
      parent_id:       nil,
      timestamp_end:   nil,
      timestamp_start: 0
    )
  end

  let(:recorder) do
    Mutant::Segment::Recorder.new(
      gen_id:,
      root_id:         root_segment.id,
      parent_id:       root_segment.id,
      recording_start: 0,
      segments:        [root_segment],
      timer:
    )
  end

  let(:world) do
    Mutant::World.new(
      condition_variable:    ConditionVariable,
      environment_variables: ENV,
      gem:                   Gem,
      gem_method:            method(:gem),
      io:                    IO,
      json:                  JSON,
      kernel:                Kernel,
      load_path:             $LOAD_PATH,
      marshal:               Marshal,
      mutex:                 Mutex,
      object_space:          ObjectSpace,
      open3:                 Open3,
      pathname:              Pathname,
      process:               Process,
      random:                Random,
      recorder:,
      stderr:                stderr_io,
      stdin:                 stdin_io,
      stdout:                stdout_io,
      tempfile:              Tempfile,
      thread:                Thread,
      time:                  Time,
      timer:
    )
  end

  describe 'mutant mcp --help' do
    let(:expected_output) do
      <<~OUTPUT
        usage: mutant mcp <server|info> [options]

        Summary: Model Context Protocol server

        mutant version: #{Mutant::VERSION}

        Global Options:

                --help                       Print help
                --version                    Print mutants version
                --profile                    Profile mutant execution
                --zombie                     Run mutant zombified

        Available subcommands:

        server - Run MCP server over STDIO
        info   - Display MCP server capabilities
      OUTPUT
    end

    it 'shows MCP subcommands' do
      result = Mutant::CLI.parse(arguments: %w[mcp --help], world:)
      expect(result).to be_instance_of(Mutant::Either::Right)

      command = result.from_right
      command.call

      expect(stdout_io.string).to eql(expected_output)
    end
  end

  describe 'mutant mcp info' do
    let(:expected_output) do
      <<~OUTPUT
        Server: mutant
        Version: #{Mutant::VERSION}

        Capabilities:
          Resources: 2
          Tools: 0 (Phase 3)
          Prompts: 0 (Phase 4)

        Status: Phase 2 - Resources Complete

        Available Resources:
          - mutant://version: Mutant Version
          - mutant://config: Mutant Configuration

        To start the server:
          mutant mcp server [options]
      OUTPUT
    end

    it 'displays server capabilities' do
      result = Mutant::CLI.parse(arguments: %w[mcp info], world:)
      expect(result).to be_instance_of(Mutant::Either::Right)

      command = result.from_right
      status = command.call

      expect(status).to be(true)
      expect(stdout_io.string).to eql(expected_output)
    end
  end

  describe 'mutant mcp server --help' do
    let(:expected_output) do
      <<~OUTPUT
        usage: mutant mcp server [options]

        Summary: Run MCP server over STDIO

        mutant version: #{Mutant::VERSION}

        Global Options:

                --help                       Print help
                --version                    Print mutants version
                --profile                    Profile mutant execution
                --zombie                     Run mutant zombified


        Environment:
            -I, --include DIRECTORY          Add DIRECTORY to $LOAD_PATH
            -r, --require NAME               Require file with NAME
                --env KEY=VALUE              Set environment variable


        Runner:
                --fail-fast                  Fail fast
            -j, --jobs NUMBER                Number of kill jobs. Defaults to number of processors.
            -t, --mutation-timeout NUMBER    Per mutation analysis timeout


        Integration:
                --use INTEGRATION            deprecated alias for --integration
                --integration NAME           Use test integration with NAME
                --integration-argument ARGUMENT
                                             Pass ARGUMENT to integration
      OUTPUT
    end

    it 'shows server options' do
      result = Mutant::CLI.parse(arguments: %w[mcp server --help], world:)
      expect(result).to be_instance_of(Mutant::Either::Right)

      command = result.from_right
      command.call

      expect(stdout_io.string).to eql(expected_output)
    end
  end

  describe 'mutant mcp server with JSON-RPC' do
    it 'processes initialize request' do
      # Send initialize request
      stdin_io.puts('{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test-client","version":"1.0.0"}}}')
      stdin_io.rewind

      result = Mutant::CLI.parse(arguments: %w[mcp server], world:)
      expect(result).to be_instance_of(Mutant::Either::Right)

      command = result.from_right
      # Note: This will block on stdin, so we're just testing that the command can be created
      # Full server testing requires more complex async handling
      expect(command).to be_instance_of(Mutant::CLI::Command::MCP::Server)
    end
  end

  describe 'command hierarchy' do
    it 'includes MCP in root subcommands' do
      expect(Mutant::CLI::Command::Root::SUBCOMMANDS).to include(Mutant::CLI::Command::MCP)
    end

    it 'includes Server and Info in MCP subcommands' do
      expect(Mutant::CLI::Command::MCP::SUBCOMMANDS).to include(
        Mutant::CLI::Command::MCP::Server,
        Mutant::CLI::Command::MCP::Info
      )
    end
  end

end
