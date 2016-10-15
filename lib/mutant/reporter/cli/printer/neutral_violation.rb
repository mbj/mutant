module Mutant
  class Reporter
    class CLI
      class Printer
        # Neutral violation env result reporter
        class NeutralViolation < self
          NEUTRAL_FAILURE_MESSAGE =
            'Mutant exited early due to neutral failures encountered during execution. '    \
            'Mutant ran your tests using semantically equivalent source code '              \
            'and the tests did not pass. This might happen if your tests are not passing, ' \
            'if executing your test suite mutates global state, '                           \
            'or if your tests otherwise do not run properly in parallel.'.freeze

          delegate(:neutral_violation_subject_results)

          # Run printer
          #
          # @return [undefined]
          def run
            visit_collection(SubjectResult, neutral_violation_subject_results)
            puts(NEUTRAL_FAILURE_MESSAGE)
          end
        end # EnvResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
