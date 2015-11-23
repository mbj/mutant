module Mutant
  class Reporter
    class CLI
      class Printer
        # Subject result printer
        class SubjectResult < self

          delegate :subject, :alive_mutation_results, :tests

          # Run report printer
          #
          # @return [undefined]
          def run
            status(subject.identification)
            tests.each do |test|
              puts("- #{test.identification}")
            end
            visit_collection(MutationResult, alive_mutation_results)
          end

        end # SubjectResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
