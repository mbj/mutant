module Mutant
  class Reporter
    class CLI
      class Printer
        class Framed < self
          # Printer for framed runner status
          class TraceStatus < self
            delegate(:active_jobs, :payload)

            # Print progress for collector
            #
            # @return [self]
            #
            # @api private
            #
            def run
              visit(Report::EnvStart, payload.env)
              visit(Progressive::TraceStatus, object)
              job_status
              self
            end

          private

            # Print worker status
            #
            # @return [undefined]
            #
            # @api private
            #
            def job_status
              return if active_jobs.empty?
              info('Active Jobs:')
              active_jobs.sort_by(&:index).each do |job|
                info('%d: %s', job.index, job.payload.identification)
              end
            end

          end # KillStatus

          # Printer for framed runner status
          class KillStatus < self

            delegate(:active_jobs, :payload)

            # Print progress for collector
            #
            # @return [self]
            #
            # @api private
            #
            def run
              visit(Report::EnvSummary, payload)
              info('Active subjects: %d', active_subject_results.length)
              visit_collection(Progress::Subject, active_subject_results)
              job_status
              self
            end

          private

            # Print worker status
            #
            # @return [undefined]
            #
            # @api private
            #
            def job_status
              return if active_jobs.empty?
              info('Active Jobs:')
              active_jobs.sort_by(&:index).each do |job|
                info('%d: %s', job.index, job.payload.identification)
              end
            end

            # Return active subject results
            #
            # @return [Array<Result::Subject>]
            #
            # @api private
            #
            def active_subject_results
              active_subjects = active_jobs.map(&:payload).flat_map(&:subject).to_set

              payload.subject_results.select do |subject_result|
                active_subjects.include?(subject_result.subject)
              end
            end

          end # KillStatus
        end # Framed
      end # Printer
    end # CLI
  end # Reporter
end # Mutant
