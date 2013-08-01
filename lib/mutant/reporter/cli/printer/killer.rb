# encoding: utf-8

module Mutant
  class Reporter
    class CLI
      class Printer

        # Printer for killer results
        class Killer < self

          handle(Mutant::Killer::Forked)

          # Run printer
          #
          # @return [undefined]
          #
          # @api private
          #
          def run
            if success?
              char('.', Color::GREEN)
              return
            end
            char('F', Color::RED)
          end

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
        end # Killer
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
