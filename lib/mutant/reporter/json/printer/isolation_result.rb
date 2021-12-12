# frozen_string_literal: true

module Mutant
  class Reporter
    class Json
      class Printer
        # Reporter for mutation results
        class IsolationResult < self
          PROCESS_ERROR_MESSAGE = <<~'MESSAGE'
            Killfork exited nonzero. Its result (if any) was ignored.
            Process status:
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

            The following exception was raised while reading the killfork result:

            ```
            %s
            %s
            %s
            ```
          MESSAGE

          TIMEOUT_ERROR_MESSAGE = <<~'MESSAGE'
            Mutation analysis ran into the configured timeout of %0.9<timeout>g seconds.
          MESSAGE

          private_constant(*constants(false))

          # Run report printer
          #
          # @return [undefined]
          def run
            print_timeout
            print_process_status
            print_log_messages
            print_exception
          end

        private

          def print_log_messages
            log = object.log

            return if log.empty?

            puts('Log messages (combined stderr and stdout):')

            log.each_line do |line|
              puts('[killfork] %<line>s' % { line: line })
            end
          end

          def print_process_status
            process_status = object.process_status or return

            if process_status.success?
              puts("Killfork: #{process_status.inspect}")
            else
              puts(PROCESS_ERROR_MESSAGE % process_status.inspect)
            end
          end

          def print_timeout
            timeout = object.timeout or return
            puts(TIMEOUT_ERROR_MESSAGE % { timeout: timeout })
          end

          def print_exception
            exception = object.exception or return

            puts(
              EXCEPTION_ERROR_MESSAGE % [
                exception.original_class,
                exception.message,
                exception.backtrace.join("\n")
              ]
            )
          end
        end # IsolationResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
