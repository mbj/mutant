# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Shared logic for printing alive mutation results
        module AliveResults
          ALIVE_EXPLANATION = <<~'MESSAGE'
            Uncovered mutations detected, exiting nonzero!
            Alive mutations require one of two actions:
            A) Keep the mutated code: Your tests specify the correct semantics,
               and the original code is redundant. Accept the mutation.
            B) Add a missing test: The original code is correct, but the tests
               do not verify the behavior the mutation removed.
          MESSAGE

          def print_alive_results(failed_subject_results)
            return if failed_subject_results.empty?

            puts(ALIVE_EXPLANATION)
            failed_subject_results.each do |subject_result|
              SubjectResult.call(output:, object: subject_result)
            end
          end
        end # AliveResults
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
