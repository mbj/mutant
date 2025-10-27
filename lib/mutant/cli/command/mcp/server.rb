# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class MCP < self
        class Server < Environment
          NAME              = 'server'
          SHORT_DESCRIPTION = 'Run MCP server over STDIO'
          SUBCOMMANDS       = [].freeze

          OPTIONS = %i[
            add_environment_options
            add_runner_options
            add_integration_options
          ].freeze

          # Execute the server command
          #
          # @return [Either<String, nil>]
          def action
            Mutant::MCP::Server.run(
              cli_config: @config,
              world:
            )
          end

        private

          def parse_remaining_arguments(arguments)
            if arguments.empty?
              Either::Right.new(self)
            else
              Either::Left.new("Unexpected arguments: #{arguments.join(' ')}")
            end
          end
        end # Server
      end # MCP
    end # Command
  end # CLI
end # Mutant
