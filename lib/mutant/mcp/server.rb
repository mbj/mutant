# frozen_string_literal: true

module Mutant
  module MCP
    # MCP Server wrapper
    class Server
      include Anima.new(:cli_config, :world)

      # Initialize and run the MCP server
      #
      # @return [Either<String, nil>]
      def self.run(cli_config:, world:)
        new(cli_config:, world:).run
      end

      # Run the server event loop
      #
      # @return [Either<String, nil>]
      def run
        begin
          mcp_server = create_mcp_server
          start_stdio_loop(mcp_server)
          Either::Right.new(nil)
        rescue StandardError => exception
          Either::Left.new("MCP server error: #{exception}")
        end
      end

    private

      # Create the MCP::Server instance
      #
      # @return [::MCP::Server]
      def create_mcp_server
        mcp_server = ::MCP::Server.new(
          name:           'mutant',
          version:        VERSION,
          tools:          [],
          prompts:        [],
          resources:      Resources.build,
          server_context: { world: }
        )

        mcp_server.resources_read_handler(&method(:handle_resource_read))

        mcp_server
      end

      # Handle MCP resource read request
      #
      # @param request [Hash]
      #
      # @return [Array<Hash>]
      def handle_resource_read(request)
        Resources.read(uri: request.fetch(:params)[:uri], cli_config:, world:)
          .map(&:to_h)
      end

      # Start the STDIO event loop
      #
      # @param mcp_server [::MCP::Server]
      #
      # @return [void]
      def start_stdio_loop(mcp_server)
        world.stdin.each_line do |line|
          line = line.strip
          next if line.empty?

          response = mcp_server.handle_json(line)

          if response
            world.stdout.puts(response)
            world.stdout.flush
          end
        rescue StandardError => exception
          error_response = create_error_response(-1, "#{exception.class}: #{exception}")
          world.stdout.puts(error_response)
          world.stdout.flush
        end
      end

      # Create a JSON-RPC error response
      #
      # @param id [Integer, String, nil]
      # @param message [String]
      #
      # @return [String]
      def create_error_response(id, message)
        {
          jsonrpc: '2.0',
          id:,
          error:   {
            code:    -32_603,
            message:
          }
        }.to_json
      end
    end # Server
  end # MCP
end # Mutant
