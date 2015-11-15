module Mutant
  class Reporter
    class CLI
      class Printer
        # Test result reporter
        class TestResult < self

          delegate :tests, :runtime

          STATUS_FORMAT = '- %d @ runtime: %s'.freeze
          OUTPUT_HEADER = 'Test Output:'.freeze
          TEST_FORMAT   = '  - %s'.freeze

          # Run test result reporter
          #
          # @return [undefined]
          def run
            info(STATUS_FORMAT, tests.length, runtime)
            tests.each do |test|
              info(TEST_FORMAT, test.identification)
            end
            puts(OUTPUT_HEADER)
            puts(object.output)
          end

        end # TestResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
