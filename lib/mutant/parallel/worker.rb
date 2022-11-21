# frozen_string_literal: true

module Mutant
  module Parallel
    class Worker
      include Adamantium, Anima.new(
        :connection,
        :index,
        :pid,
        :process,
        :var_active_jobs,
        :var_final,
        :var_running,
        :var_sink,
        :var_source
      )

      private(*anima.attribute_names)

      public :index

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/ParameterLists
      def self.start(world:, block:, process_name:, **attributes)
        io      = world.io
        process = world.process

        request  = Pipe.from_io(io)
        response = Pipe.from_io(io)

        pid = process.fork do
          world.thread.current.name = process_name
          world.process.setproctitle(process_name)

          Child.new(
            block:      block,
            connection: Pipe::Connection.from_pipes(
              marshal: world.marshal,
              reader:  request,
              writer:  response
            )
          ).call
        end

        new(
          pid:        pid,
          process:    process,
          connection: Pipe::Connection.from_pipes(
            marshal: world.marshal,
            reader:  response,
            writer:  request
          ),
          **attributes
        )
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/ParameterLists

      # Run worker payload
      #
      # @return [self]
      def call
        loop do
          job = next_job or break

          job_start(job)

          result = connection.call(job.payload)

          job_done(job)

          break if add_result(result)
        end

        finalize

        self
      end

      def signal
        process.kill('TERM', pid)
        self
      end

      def join
        process.wait(pid)
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

      class Child
        include Anima.new(:block, :connection)

        def call
          loop do
            connection.send_value(block.call(connection.receive_value))
          end
        end
      end
      private_constant :Child
    end # Worker
  end # Parallel
end # Mutant
