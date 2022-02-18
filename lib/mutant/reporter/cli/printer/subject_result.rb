# frozen_string_literal: true

module Mutant
  class Reporter
    class CLI
      class Printer
        # Subject result printer
        class SubjectResult < self

          delegate :subject, :uncovered_results, :tests

          # Run report printer
          #
          # @return [undefined]
          def run
            unless env.config.compacted_log
              status(subject.identification)
              tests.each do |test|
                puts("- #{test.identification}")
              end
            end
            visit_collection(CoverageResult, uncovered_results)
          end

        end # SubjectResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
