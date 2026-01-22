# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class IPC < self
        NAME              = 'ipc'
        SHORT_DESCRIPTION = 'IPC worker for Rust orchestrator'
        SUBCOMMANDS       = [].freeze
        OPTIONS           = %i[add_socket_options].freeze

        def initialize(_arguments)
          super
          @socket_path = nil
        end

        def action
          return Either::Left.new('--socket is required') unless @socket_path

          Mutant::IPC.new(socket_path: @socket_path, world:).call
        end

      private

        def add_socket_options(parser)
          parser.separator('IPC Options:')

          parser.on('--socket PATH', 'Unix domain socket path') do |path|
            @socket_path = path
          end
        end

        def parse_remaining_arguments(arguments)
          if arguments.empty?
            Either::Right.new(self)
          else
            Either::Left.new("Unexpected arguments: #{arguments.inspect}")
          end
        end
      end # IPC
    end # Command
  end # CLI
end # Mutant
