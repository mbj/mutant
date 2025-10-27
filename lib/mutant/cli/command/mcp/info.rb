# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class MCP < self
        class Info < self
          NAME              = 'info'
          SHORT_DESCRIPTION = 'Display MCP server capabilities'
          SUBCOMMANDS       = [].freeze
          OPTIONS           = [].freeze

          # Execute the info command
          #
          # @return [Either<String, nil>]
          def action
            print_server_info
            Either::Right.new(nil)
          end

        private

          def print_server_info
            resources = Mutant::MCP::Resources.build

            world.stdout.puts(<<~INFO)
              Server: mutant
              Version: #{VERSION}

              Capabilities:
                Resources: #{resources.length}
                Tools: 0 (Phase 3)
                Prompts: 0 (Phase 4)

              Status: Phase 2 - Resources Complete

              Available Resources:
            INFO

            resources.each do |resource|
              world.stdout.puts("  - #{resource.uri}: #{resource.name}")
            end

            world.stdout.puts(<<~INFO)

              To start the server:
                mutant mcp server [options]
            INFO
          end

          def parse_remaining_arguments(arguments)
            if arguments.empty?
              Either::Right.new(self)
            else
              Either::Left.new("Unexpected arguments: #{arguments.join(' ')}")
            end
          end
        end # Info
      end # MCP
    end # Command
  end # CLI
end # Mutant
