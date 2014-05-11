# encoding: utf-8

module Mutant
  class Reporter
    class CLI
      class Printer
        # Abstract base class for process printers
        class Progress < self
          include AbstractType

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
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
