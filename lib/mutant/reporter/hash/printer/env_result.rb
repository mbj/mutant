module Mutant
  class Reporter
    class Hash
      class Printer
        # Full env result reporter
        class EnvResult < self
          delegate(:failed_subject_results)
          delegate(:subject_results)

          # Run printer
          #
          # @return [undefined]
          #
          # @api private
          def run
            {
              failed_subject_results: visit_collection(SubjectResult, failed_subject_results),
              success_subject_results: visit_collection(SubjectResult, subject_results.select(&:success?)),
              env_progress: visit(EnvProgress, object)
            }
          end
        end # EnvResult
      end # Printer
    end # Hash
  end # Reporter
end # Mutant
