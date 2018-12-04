# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Reporter for mutation results
        #
        # :reek:TooManyConstants
        class IsolationResult < self
          ERROR_MESSAGE = <<~'MESSAGE'
            Killing the mutation resulted in an integration error.
            This is the case when the tests selected for the current mutation
            did not produce a test result, but instead an exception was raised.

            This may point to the following problems:
            * Bug in mutant
            * Bug in the ruby interpreter
            * Bug in your test suite
            * Bug in your test suite under concurrency

            The following exception was raised:

            ```
            %s
            %s
            ```
          MESSAGE

          private_constant(*constants(false))

          # Run report printer
          #
          # @return [undefined]
          def run
            if object.success?
              visit(TestResult, object.value)
            else
              visit_error_result
            end
          end

        private

          # Visit failed test results
          #
          # @return [undefined]
          def visit_error_result
            exception = object.error

            puts(
              ERROR_MESSAGE % [
                exception.inspect,
                exception.backtrace.join("\n")
              ]
            )
          end
        end # IsolationResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
