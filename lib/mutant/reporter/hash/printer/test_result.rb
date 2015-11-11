module Mutant
  class Reporter
    class Hash
      class Printer
        # Test result reporter
        class TestResult < self

          delegate :tests, :runtime

          # Run test result reporter
          #
          # @return [undefined]
          #
          # @api private
          def run
            {
              count: tests.length,
              runtime: runtime,
              tests: tests.map(&:identification),
              output: object.output
            }
          end

        end # TestResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
