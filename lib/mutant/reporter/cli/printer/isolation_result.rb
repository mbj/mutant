# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Reporter for mutation results
        #
        # :reek:TooManyConstants
        class IsolationResult < self
          CHILD_ERROR_MESSAGE = <<~'MESSAGE'
            Killfork exited nonzero. Its result (if any) was ignored:
            %s
          MESSAGE

          EXCEPTION_ERROR_MESSAGE = <<~'MESSAGE'
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

          FORK_ERROR_MESSAGE = <<~'MESSAGE'
            Forking the child process to isolate the mutation in failed.
            This meant that either the RubyVM or your OS was under too much
            pressure to add another child process.

            Possible solutions are:
            * Reduce concurrency
            * Reduce locks
          MESSAGE

          MAP = {
            Isolation::Fork::ChildError   => :visit_child_error,
            Isolation::Fork::ForkError    => :visit_fork_error,
            Isolation::Result::ErrorChain => :visit_chain,
            Isolation::Result::Exception  => :visit_exception,
            Isolation::Result::Success    => :visit_success
          }.freeze

          private_constant(*constants(false))

          # Run report printer
          #
          # @return [undefined]
          def run
            __send__(MAP.fetch(object.class))
          end

        private

          # Visit successful isolation result
          #
          # @return [undefined]
          def visit_success
            visit(TestResult, object.value)
          end

          # Visit child error isolation result
          #
          # @return [undefined]
          def visit_child_error
            puts(CHILD_ERROR_MESSAGE % object.value.inspect)
          end

          # Visit fork error isolation result
          #
          # @return [undefined]
          def visit_fork_error
            puts(FORK_ERROR_MESSAGE)
          end

          # Visit exception isolation result
          #
          # @return [undefined]
          def visit_exception
            exception = object.value

            puts(
              EXCEPTION_ERROR_MESSAGE % [
                exception.inspect,
                exception.backtrace.join("\n")
              ]
            )
          end

          # Visit chain
          #
          # @return [undefined]
          def visit_chain
            printer = self.class

            visit(printer, object.value)
            visit(printer, object.next)
          end
        end # IsolationResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
