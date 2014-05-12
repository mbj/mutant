module Mutant
  class Reporter
    class CLI
      class Progress

        # Mutation progress reporter
        class Mutation < self

          handle(Runner::Mutation)

          SUCCESS = '.'.freeze
          FAILURE = 'F'.freeze

          # Run printer
          #
          # @return [undefined]
          #
          # @api private
          #
          def run
            char(success? ? SUCCESS : FAILURE)
          end

        private

          # Write colorized char
          #
          # @param [String] char
          #
          # @return [undefined]
          #
          # @api private
          #
          def char(char)
            output.write(colorize(status_color, char))
            output.flush
          end

        end # Mutation
      end # Progress
    end # CLI
  end # Reporter
end # Mutant
