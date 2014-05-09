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
              if success?
                char(SUCCESS, Color::GREEN)
              else
                char(FAILURE, Color::RED)
              end
            end

          private

            # Write colorized char
            #
            # @param [String] char
            # @param [Color]
            #
            # @return [undefined]
            #
            # @api private
            #
            def char(char, color)
              output.write(colorize(color, char))
              output.flush
            end

          end # Mutation
        end # Progress
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
