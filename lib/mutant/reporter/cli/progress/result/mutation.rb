module Mutant
  class Reporter
    class CLI
      class Progress
        class Result
          # Mutation test result progress reporter
          class Mutation < self

            handle(Mutant::Result::Mutation)

            SUCCESS = '.'.freeze
            FAILURE = 'F'.freeze

            # Run printer
            #
            # @return [self]
            #
            # @api private
            #
            def run
              char(success? ? SUCCESS : FAILURE)
              self
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
        end # Result
      end # Progress
    end # CLI
  end # Reporter
end # Mutant
