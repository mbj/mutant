# frozen_string_literal: true

module Mutant
  module Parallel
    class Worker
      class Config
        include Adamantium, Anima.new(
          :block,
          :index,
          :on_process_start,
          :process_name,
          :var_active_jobs,
          :var_final,
          :var_running,
          :var_sink,
          :var_source,
          :world
        )
      end

      include Adamantium, Anima.new(:connection, :config, :pid)

      def self.start(**attributes)
        start_config(Config.new(**attributes))
      end

      # rubocop:disable Metrics/MethodLength
      def self.start_config(config)
        world   = config.world
        io      = world.io
        marshal = world.marshal

        request  = Pipe.from_io(io)
        response = Pipe.from_io(io)

        pid = world.process.fork do
          run_child(
            config:     config,
            connection: Pipe::Connection.from_pipes(marshal: marshal, reader: request, writer: response)
          )
        end

        new(
          pid:        pid,
          config:     config,
          connection: Pipe::Connection.from_pipes(marshal: marshal, reader: response, writer: request)
        )
      end
      private_class_method :start_config
      # rubocop:enable Metrics/MethodLength

      def self.run_child(config:, connection:)
        world = config.world

        world.thread.current.name = config.process_name
        world.process.setproctitle(config.process_name)

        config.on_process_start.call(index: config.index)

        loop do
          connection.send_value(config.block.call(connection.receive_value))
        end
      end
      private_class_method :run_child

      def index
        config.index
      end

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

      def process
        config.world.process
      end

      def next_job
        config.var_source.with do |source|
          source.next if source.next?
        end
      end

      def add_result(result)
        config.var_sink.with do |sink|
          sink.result(result)
          sink.stop?
        end
      end

      def job_start(job)
        config.var_active_jobs.with do |active_jobs|
          active_jobs << job
        end
      end

      def job_done(job)
        config.var_active_jobs.with do |active_jobs|
          active_jobs.delete(job)
        end
      end

      def finalize
        config.var_final.put(nil) if config.var_running.modify(&:pred).zero?
      end
    end # Worker
  end # Parallel
end # Mutant
