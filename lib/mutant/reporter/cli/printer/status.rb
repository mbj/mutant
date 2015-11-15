module Mutant
  class Reporter
    class CLI
      class Printer
        # Printer for runner status
        class Status < self

          delegate(:active_jobs, :payload)

          ACTIVE_JOB_HEADER = 'Active Jobs:'.freeze
          ACTIVE_JOB_FORMAT = '%d: %s'.freeze

          # Print progress for collector
          #
          # @return [undefined]
          def run
            visit(EnvProgress, payload)
            job_status
            info('Active subjects: %d', active_subject_results.length)
            visit_collection(SubjectProgress, active_subject_results)
          end

        private

          # Print worker status
          #
          # @return [undefined]
          def job_status
            return if active_jobs.empty?
            info(ACTIVE_JOB_HEADER)
            active_jobs.sort_by(&:index).each do |job|
              info(ACTIVE_JOB_FORMAT, job.index, job.payload.identification)
            end
          end

          # Active subject results
          #
          # @return [Array<Result::Subject>]
          def active_subject_results
            active_subjects = active_jobs.map(&:payload).flat_map(&:subject)

            payload.subject_results.select do |subject_result|
              active_subjects.include?(subject_result.subject)
            end
          end

        end # Status
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
