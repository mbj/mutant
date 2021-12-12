# frozen_string_literal: true

module Mutant
  class Reporter
    class Json
      class Printer
        # Reporter for mutation coverage results
        class CoverageResult < self
          # Run report printer
          #
          # @return [undefined]
          def run
            visit(MutationResult, object.mutation_result)
          end
        end # Printer
      end # Coverage
    end # CLI
  end # Reporter
end # Mutant
