# frozen_string_literal: true

module Mutant
  module Parallel
    # Driver for parallelized execution
    class Driver
      include Adamantium::Flat, Anima.new(
        :threads,
        :var_active_jobs,
        :var_final,
        :var_sink
      )

      private(*anima.attribute_names)

      # Wait for computation to finish, with timeout
      #
      # @param [Float] timeout
      #
      # @return [Variable::Result<Sink#status>]
      #   current status
      def wait_timeout(timeout)
        var_final.take_timeout(timeout)

        finalize(status)
      end

    private

      def finalize(status)
        status.tap do
          threads.each(&:join) if status.done?
        end
      end

      def status
        var_active_jobs.with do |active_jobs|
          var_sink.with do |sink|
            Status.new(
              active_jobs: active_jobs.dup.freeze,
              done:        threads.all? { |thread| !thread.alive? },
              payload:     sink.status
            )
          end
        end
      end
    end # Driver
  end # Parallel
end # Mutant
