module Mutant
  class Reporter
    class CLI
      class Report

        # Subject report printer
        class Subject < self

          delegate :subject, :failed_mutations

          handle(Mutant::Result::Subject)

          # Run report printer
          #
          # @return [self]
          #
          # @api private
          #
          def run
            status(subject.identification)
            subject.tests.each do |test|
              puts("- #{test.identification}")
            end
            visit_collection(object.alive_mutation_results)
            self
          end

        end # Subject
      end # Report
    end # CLI
  end # Reporter
end # Mutant
