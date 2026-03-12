# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Full env result reporter
        class EnvResult < self
          delegate(:failed_subject_results)

          ALIVE_EXPLANATION = <<~'MESSAGE'
            Alive mutations require one of two actions:
            A) Keep the mutated code: Your tests specify the correct semantics,
               and the original code is redundant. Accept the mutation.
            B) Add a missing test: The original code is correct, but the tests
               do not verify the behavior the mutation removed.
          MESSAGE

          # Run printer
          #
          # @return [undefined]
          def run
            puts(ALIVE_EXPLANATION) if failed_subject_results.any?
            visit_collection(SubjectResult, failed_subject_results)
            visit(EnvProgress, object)
          end
        end # EnvResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
