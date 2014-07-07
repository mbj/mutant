module Mutant
  class Reporter
    class CLI
      class Report
        # Test result reporter
        class Test < self

          handle(Mutant::Result::Test)

          delegate :test, :runtime

          # Run test result reporter
          #
          # @return [self]
          #
          # @api private
          #
          def run
            status('- %s / runtime: %s', test.identification, object.runtime)
            puts('Test Output:')
            puts(object.output)
          end

        end
      end # Report
    end # CLI
  end # Reporter
end # Mutant
