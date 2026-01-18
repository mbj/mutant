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
          :timeout,
          :var_active_jobs,
          :var_final,
          :var_running,
          :var_sink,
          :var_source,
          :world
        )
      end

      include Adamantium, Anima.new(:config, :connection, :log_reader, :pid, :response_reader)

      def self.start(**attributes)
        start_config(Config.new(**attributes))
      end

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def self.start_config(config)
        world   = config.world
        io      = world.io
        marshal = world.marshal

        log, request, response = Pipe.from_io(io), Pipe.from_io(io), Pipe.from_io(io)

        pid = world.process.fork do
          log_writer = log.to_writer

          world.stderr.reopen(log_writer)
          world.stdout.reopen(log_writer)

          run_child(
            config:,
            connection: Connection.from_pipes(marshal:, reader: request, writer: response),
            log_writer:
          )
        end

        connection = Connection.from_pipes(marshal:, reader: response, writer: request)

        new(
          config:,
          connection:,
          log_reader:      log.to_reader,
          response_reader: connection.reader.io,
          pid:
        )
      end
      private_class_method :start_config
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def self.run_child(config:, connection:, log_writer:)
        world = config.world

        world.thread.current.name = config.process_name
        world.process.setproctitle(config.process_name)

        config.on_process_start.call(index: config.index)

        loop do
          value = config.block.call(connection.receive_value)
          log_writer.flush
          connection.send_value(value)
        end
      end
      private_class_method :run_child

      def index = config.index

      # Run worker loop
      #
      # @return [self]
      #
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def call
        loop do
          job = next_job or break

          job_start(job)

          connection.send_value(job.payload)

          response = Connection::Reader.read_response(
            deadline:        config.world.deadline(config.timeout),
            io:              config.world.io,
            job:,
            log_reader:,
            marshal:         config.world.marshal,
            response_reader:
          )

          job_done(job)

          break if add_response(response) || response.error
        end

        finalize

        self
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      def signal = tap { process.kill('TERM', pid) }

      def join = tap { process.wait(pid) }

    private

      def process = config.world.process

      def next_job
        config.var_source.with do |source|
          source.next if source.next?
        end
      end

      def add_response(response)
        config.var_sink.with do |sink|
          sink.response(response)
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
