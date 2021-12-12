# frozen_string_literal: true

module Mutant
  class Reporter
    class Json
      class Printer
        # Subject result printer
        class SubjectResult < self

          delegate :subject, :uncovered_results, :tests

          # Run report printer
          #
          # @return [undefined]
          def run
            puts "---\n---\n"
            puts 'Failed subject:'
            status(subject.identification)
            visit_collection(CoverageResult, uncovered_results)
          end

        end # SubjectResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
