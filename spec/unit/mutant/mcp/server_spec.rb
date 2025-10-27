# frozen_string_literal: true

RSpec.describe Mutant::MCP::Server do
  let(:cli_config) { Mutant::Config::DEFAULT }

  let(:stdin) { instance_double(IO, :stdin) }
  let(:stdout) { instance_double(IO, :stdout) }

  let(:world) do
    instance_double(
      Mutant::World,
      json: JSON,
      stdin:,
      stdout:
    )
  end

  let(:mcp_server_instance) { instance_double(::MCP::Server) }

  before do
    allow(::MCP::Server).to receive(:new).and_return(mcp_server_instance)
    allow(mcp_server_instance).to receive(:resources_read_handler)
  end

  describe '.run' do
    context 'when stdin provides valid messages' do
      before do
        allow(stdin).to receive(:each_line).and_yield('{"jsonrpc":"2.0","id":1,"method":"ping"}')
        allow(mcp_server_instance).to receive(:handle_json).and_return('{"jsonrpc":"2.0","id":1,"result":"pong"}')
        allow(stdout).to receive(:puts)
        allow(stdout).to receive(:flush)
      end

      it 'creates MCP server with correct arguments and resources built with world' do
        described_class.run(cli_config:, world:)

        expect(::MCP::Server).to have_received(:new) do |args|
          expect(args[:name]).to eql('mutant')
          expect(args[:version]).to eql(Mutant::VERSION)
          expect(args[:tools]).to eql([])
          expect(args[:prompts]).to eql([])
          expect(args[:resources]).to be_an(Array)
          expect(args[:resources].length).to eql(2)
          expect(args[:server_context]).to eql({ world: })
        end
      end

      it 'registers resources_read_handler with correct block using world' do
        captured_block = nil

        allow(mcp_server_instance).to receive(:resources_read_handler) do |&block|
          captured_block = block
        end

        described_class.run(cli_config:, world:)

        expect(captured_block).not_to be_nil

        # Verify the block works correctly and uses world (not nil)
        test_request = { params: { uri: 'mutant://version' } }
        result = captured_block.call(test_request)

        expect(result).to eql(
          [
            {
              uri:       'mutant://version',
              mime_type: 'application/json',
              text:      JSON.pretty_generate(
                'version'      => Mutant::VERSION,
                'ruby_version' => RUBY_VERSION,
                'platform'     => RUBY_PLATFORM
              )
            }
          ]
        )

        # Verify world.json was actually used (proves world: not world: nil)
        expect(world).to have_received(:json)
      end

      it 'passes cli_config through to resource handlers' do
        # Set up world so Config.load can run
        allow(world).to receive(:pathname).and_return(Pathname)
        allow(world).to receive(:environment_variables).and_return({})

        # Use a cli_config with specific values
        specific_cli_config = Mutant::Config::DEFAULT.with(jobs: 10)

        # Set up stdin to send a config resource read request
        request_json = '{"jsonrpc":"2.0","id":1,"method":"resources/read","params":{"uri":"mutant://config"}}'
        allow(stdin).to receive(:each_line).and_yield(request_json)

        # Capture the resource handler when it's registered
        resource_handler = nil
        allow(mcp_server_instance).to receive(:resources_read_handler) do |&block|
          resource_handler = block
        end

        # Mock handle_json to call the captured resource handler
        allow(mcp_server_instance).to receive(:handle_json) do |input|
          request = JSON.parse(input, symbolize_names: true)
          contents = resource_handler.call(request)

          {
            jsonrpc: '2.0',
            id:      request[:id],
            result:  { contents: }
          }.to_json
        end

        # Capture stdout response
        response = nil
        allow(stdout).to receive(:puts) { |data| response = data }
        allow(stdout).to receive(:flush)

        described_class.run(cli_config: specific_cli_config, world:)

        # Parse the full response
        parsed_response = JSON.parse(response)
        actual_config_text = parsed_response.dig('result', 'contents', 0, 'text')
        actual_config = JSON.parse(actual_config_text)

        # Build expected config and normalize object inspects
        expected_config = Mutant::Config.load(cli_config: specific_cli_config, world:).from_right
        expected_config_text = JSON.pretty_generate(expected_config.to_h)
        expected_config_parsed = JSON.parse(expected_config_text)

        # Helper to normalize object inspect strings by removing memory addresses
        normalize = lambda do |obj|
          case obj
          when Hash
            obj.transform_values { |v| normalize.call(v) }
          when Array
            obj.map { |v| normalize.call(v) }
          when String
            # Replace object inspect patterns like "#<Module::ClassName:0xADDRESS>" with "#<Module::ClassName>"
            obj.gsub(/#<(.+):0x[0-9a-f]+>/, '#<\1>')
          else
            obj
          end
        end

        actual_normalized_response = {
          'jsonrpc' => parsed_response['jsonrpc'],
          'id'      => parsed_response['id'],
          'result'  => {
            'contents' => [
              {
                'uri'       => parsed_response.dig('result', 'contents', 0, 'uri'),
                'mime_type' => parsed_response.dig('result', 'contents', 0, 'mime_type'),
                'text'      => normalize.call(actual_config)
              }
            ]
          }
        }

        expected_normalized_response = {
          'jsonrpc' => '2.0',
          'id'      => 1,
          'result'  => {
            'contents' => [
              {
                'uri'       => 'mutant://config',
                'mime_type' => 'application/json',
                'text'      => normalize.call(expected_config_parsed)
              }
            ]
          }
        }

        expect(actual_normalized_response).to eql(expected_normalized_response)
      end

      it 'returns Right with nil' do
        result = described_class.run(cli_config:, world:)
        expect(result).to be_instance_of(Mutant::Either::Right)
        expect(result.from_right).to be_nil
      end

      it 'sends response to stdout' do
        described_class.run(cli_config:, world:)
        expect(stdout).to have_received(:puts).with('{"jsonrpc":"2.0","id":1,"result":"pong"}')
      end

      it 'flushes stdout' do
        described_class.run(cli_config:, world:)
        expect(stdout).to have_received(:flush)
      end
    end

    context 'when stdin provides valid message with XSpec verification' do
      let(:raw_expectations) do
        [
          {
            receiver:  stdin,
            selector:  :each_line,
            arguments: [],
            reaction:  { yields: ['{"jsonrpc":"2.0","id":1,"method":"test"}'] }
          },
          {
            receiver:  mcp_server_instance,
            selector:  :handle_json,
            arguments: ['{"jsonrpc":"2.0","id":1,"method":"test"}'],
            reaction:  { return: '{"jsonrpc":"2.0","id":1,"result":"ok"}' }
          },
          {
            receiver:  stdout,
            selector:  :puts,
            arguments: ['{"jsonrpc":"2.0","id":1,"result":"ok"}'],
            reaction:  { return: nil }
          },
          {
            receiver:  stdout,
            selector:  :flush,
            arguments: [],
            reaction:  { return: nil }
          }
        ]
      end

      it 'follows exact event sequence for response' do
        verify_events do
          result = described_class.run(cli_config:, world:)
          expect(result).to be_instance_of(Mutant::Either::Right)
        end
      end
    end

    context 'when stdin provides empty lines' do
      before do
        allow(stdin).to receive(:each_line).and_yield('  ').and_yield("\n")
        allow(mcp_server_instance).to receive(:handle_json)
        allow(stdout).to receive(:puts)
        allow(stdout).to receive(:flush)
      end

      it 'skips empty lines' do
        described_class.run(cli_config:, world:)
        expect(mcp_server_instance).not_to have_received(:handle_json)
      end
    end

    context 'when stdin provides empty lines followed by valid message' do
      before do
        allow(stdin).to receive(:each_line)
          .and_yield('  ')
          .and_yield("\n")
          .and_yield('{"jsonrpc":"2.0","id":1,"method":"test"}')
        allow(mcp_server_instance).to receive(:handle_json).and_return('{"jsonrpc":"2.0","id":1,"result":"ok"}')
        allow(stdout).to receive(:puts)
        allow(stdout).to receive(:flush)
      end

      it 'continues processing after empty lines' do
        described_class.run(cli_config:, world:)
        expect(mcp_server_instance).to have_received(:handle_json).with('{"jsonrpc":"2.0","id":1,"method":"test"}')
        expect(stdout).to have_received(:puts).with('{"jsonrpc":"2.0","id":1,"result":"ok"}')
      end
    end

    context 'when mcp_server_instance.handle_json returns nil' do
      before do
        allow(stdin).to receive(:each_line).and_yield('{"jsonrpc":"2.0","method":"notification"}')
        allow(mcp_server_instance).to receive(:handle_json).and_return(nil)
        allow(stdout).to receive(:puts)
        allow(stdout).to receive(:flush)
      end

      it 'does not send response to stdout' do
        described_class.run(cli_config:, world:)
        expect(stdout).not_to have_received(:puts)
      end
    end

    context 'when message processing raises an error' do
      before do
        allow(stdin).to receive(:each_line).and_yield('invalid json')
        allow(mcp_server_instance).to receive(:handle_json).and_raise(StandardError.new('Parse error'))
        allow(stdout).to receive(:puts)
        allow(stdout).to receive(:flush)
      end

      it 'sends error response' do
        described_class.run(cli_config:, world:)
        expected_response = '{"jsonrpc":"2.0","id":-1,"error":{"code":-32603,"message":"StandardError: Parse error"}}'
        expect(stdout).to have_received(:puts).with(expected_response)
      end

      it 'flushes stdout after error response' do
        described_class.run(cli_config:, world:)
        expect(stdout).to have_received(:flush).at_least(:once)
      end
    end

    context 'when message processing raises error with XSpec verification' do
      let(:exception) { StandardError.new('Test error') }

      let(:raw_expectations) do
        [
          {
            receiver:  stdin,
            selector:  :each_line,
            arguments: [],
            reaction:  { yields: ['invalid'] }
          },
          {
            receiver:  mcp_server_instance,
            selector:  :handle_json,
            arguments: ['invalid'],
            reaction:  { exception: }
          },
          {
            receiver:  stdout,
            selector:  :puts,
            arguments: ['{"jsonrpc":"2.0","id":-1,"error":{"code":-32603,"message":"StandardError: Test error"}}'],
            reaction:  { return: nil }
          },
          {
            receiver:  stdout,
            selector:  :flush,
            arguments: [],
            reaction:  { return: nil }
          }
        ]
      end

      it 'follows exact event sequence for error handling' do
        verify_events do
          result = described_class.run(cli_config:, world:)
          expect(result).to be_instance_of(Mutant::Either::Right)
        end
      end
    end

    context 'when server initialization fails' do
      before do
        allow(::MCP::Server).to receive(:new).and_raise(StandardError.new('Init failed'))
      end

      it 'returns Left with error message' do
        result = described_class.run(cli_config:, world:)
        expect(result).to be_instance_of(Mutant::Either::Left)
        expect(result.from_left).to eql('MCP server error: Init failed')
      end
    end
  end

  describe '#handle_resource_read' do
    let(:server) { described_class.new(cli_config:, world:) }

    context 'when reading version resource' do
      let(:request) do
        {
          params: {
            uri: 'mutant://version'
          }
        }
      end

      it 'returns array of resource contents as hashes' do
        result = server.send(:handle_resource_read, request)

        expect(result).to eql(
          [
            {
              uri:       'mutant://version',
              mime_type: 'application/json',
              text:      JSON.pretty_generate(
                'version'      => Mutant::VERSION,
                'ruby_version' => RUBY_VERSION,
                'platform'     => RUBY_PLATFORM
              )
            }
          ]
        )
      end
    end

    context 'when reading config resource' do
      let(:config_double) do
        instance_double(
          Mutant::Config,
          to_h: {
            integration: { name: 'rspec' },
            jobs:        4
          }
        )
      end

      let(:request) do
        {
          params: {
            uri: 'mutant://config'
          }
        }
      end

      before do
        allow(Mutant::Config).to receive(:load)
          .with(cli_config:, world:)
          .and_return(Mutant::Either::Right.new(config_double))
      end

      it 'returns loaded config as JSON hash' do
        result = server.send(:handle_resource_read, request)

        expect(result).to eql(
          [
            {
              uri:       'mutant://config',
              mime_type: 'application/json',
              text:      JSON.pretty_generate(
                integration: { name: 'rspec' },
                jobs:        4
              )
            }
          ]
        )
      end
    end

    context 'when reading unknown resource' do
      let(:request) do
        {
          params: {
            uri: 'mutant://unknown'
          }
        }
      end

      it 'returns empty array' do
        result = server.send(:handle_resource_read, request)

        expect(result).to eql([])
      end
    end

    context 'when request has missing uri' do
      let(:request_missing_uri) do
        {
          params: {}
        }
      end

      it 'handles missing uri gracefully with []' do
        # Using [:uri] returns nil, fetch would raise
        expect(request_missing_uri[:params][:uri]).to be_nil
        result = server.send(:handle_resource_read, request_missing_uri)
        expect(result).to eql([])
      end
    end
  end

  describe '#create_error_response' do
    let(:server) { described_class.new(cli_config:, world:) }

    it 'creates JSON-RPC error response' do
      result = server.send(:create_error_response, 1, 'Test error')

      expect(JSON.parse(result)).to eql(
        {
          'jsonrpc' => '2.0',
          'id'      => 1,
          'error'   => {
            'code'    => -32_603,
            'message' => 'Test error'
          }
        }
      )
    end

    it 'handles nil id' do
      result = server.send(:create_error_response, nil, 'Error')

      expect(JSON.parse(result)).to eql(
        {
          'jsonrpc' => '2.0',
          'id'      => nil,
          'error'   => {
            'code'    => -32_603,
            'message' => 'Error'
          }
        }
      )
    end
  end
end
