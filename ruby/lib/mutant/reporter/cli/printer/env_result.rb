# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Full env result reporter
        class EnvResult < self
          include AliveResults

          delegate(:failed_subject_results)

          # Run printer
          #
          # @return [undefined]
          def run
            print_alive_results(failed_subject_results)
            visit(EnvProgress, object)
          end
        end # EnvResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
