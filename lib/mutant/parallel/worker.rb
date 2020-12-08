# frozen_string_literal: true

module Mutant
  module Parallel
    class Worker
      include Adamantium::Flat, Anima.new(
        :processor,
        :var_active_jobs,
        :var_final,
        :var_running,
        :var_sink,
        :var_source
      )

      private(*anima.attribute_names)

      # Run worker payload
      #
      # @return [self]
      def call
        loop do
          job = next_job or break

          job_start(job)

          result = processor.call(job.payload)

          job_done(job)

          break if add_result(result)
        end

        finalize

        self
      end

    private

      def next_job
        var_source.with do |source|
          source.next if source.next?
        end
      end

      def add_result(result)
        var_sink.with do |sink|
          sink.result(result)
          sink.stop?
        end
      end

      def job_start(job)
        var_active_jobs.with do |active_jobs|
          active_jobs << job
        end
      end

      def job_done(job)
        var_active_jobs.with do |active_jobs|
          active_jobs.delete(job)
        end
      end

      def finalize
        var_final.put(nil) if var_running.modify(&:pred).zero?
      end

    end # Worker
  end # Parallel
end # Mutant
