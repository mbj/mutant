module Mutant
  class Reporter
    class Hash
      class Printer
        # Subject result printer
        class SubjectResult < self

          delegate :subject, :alive_mutation_results, :tests

          # Run report printer
          #
          # @return [undefined]
          #
          # @api private
          def run
            {
              identification: subject.identification,
              tests: tests.map(&:identification),
              mutation_result: visit_collection(MutationResult, alive_mutation_results)
            }
          end

        end # SubjectResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
