module Mutant
  class Reporter
    class CLI
      class Printer
        # Full env result reporter
        class EnvResult < self
          delegate(:failed_subject_results)

          # Run printer
          #
          # @return [undefined]
          def run
            visit_collection(SubjectResult, failed_subject_results)
            visit(EnvProgress, object)
          end
        end # EnvResult
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
