# frozen_string_literal: true

module Mutant
  module Parallel
    # Master parallel worker
    class Master
      include Concord.new(:config, :mailbox)

      private_class_method :new

      # Run master
      #
      # @param [Config] config
      #
      # @return [Actor::Sender]
      def self.call(config)
        config.env.spawn do |mailbox|
          new(config, mailbox).__send__(:run)
        end
      end

      # Initialize object
      #
      # @return [undefined]
      def initialize(*)
        super

        @stop        = false
        @workers     = 0
        @active_jobs = Set.new
        @index       = 0
      end

    private

      # Run work loop
      #
      # rubocop:disable MethodLength
      #
      # @return [undefined]
      def run
        config.jobs.times do
          @workers += 1
          config.env.spawn do |worker_mailbox|
            Worker.run(
              mailbox:   worker_mailbox,
              processor: config.processor,
              parent:    mailbox.sender
            )
          end
        end

        receive_loop
      end

      MAP = IceNine.deep_freeze(
        ready:  :handle_ready,
        status: :handle_status,
        result: :handle_result,
        stop:   :handle_stop
      )

      # Handle messages
      #
      # @param [Actor::Message] message
      #
      # @return [undefined]
      def handle(message)
        type, payload = message.type, message.payload
        method = MAP.fetch(type) do
          fail Actor::ProtocolError, "Unexpected message: #{type.inspect}"
        end
        __send__(method, payload)
      end

      # Run receive loop
      #
      # @return [undefined]
      def receive_loop
        handle(mailbox.receiver.call) until @workers.zero? && @stop
      end

      # Handle status
      #
      # @param [Actor::Sender] sender
      #
      # @return [undefined]
      def handle_status(sender)
        status = Status.new(
          payload:     sink.status,
          done:        sink.stop? || @workers.zero?,
          active_jobs: @active_jobs.dup.freeze
        )
        sender.call(Actor::Message.new(:status, status))
      end

      # Handle result
      #
      # @param [JobResult] job_result
      #
      # @return [undefined]
      def handle_result(job_result)
        @active_jobs.delete(job_result.job)
        sink.result(job_result.payload)
      end

      # Handle stop
      #
      # @param [Actor::Sender] sender
      #
      # @return [undefined]
      def handle_stop(sender)
        @stop = true
        receive_loop
        sender.call(Actor::Message.new(:stop))
      end

      # Handle ready worker
      #
      # @param [Actor::Sender] sender
      #
      # @return [undefined]
      def handle_ready(sender)
        if stop_work?
          stop_worker(sender)
          return
        end

        sender.call(Actor::Message.new(:job, next_job))
      end

      # Next job if any
      #
      # @return [Job]
      #   if next job is available
      #
      # @return [nil]
      def next_job
        Job.new(
          index:   @index,
          payload: source.next
        ).tap do |job|
          @index += 1
          @active_jobs << job
        end
      end

      # Stop worker
      #
      # @param [Actor::Sender] sender
      #
      # @return [undefined]
      def stop_worker(sender)
        @workers -= 1
        sender.call(Actor::Message.new(:stop))
      end

      # Test if scheduling stopped
      #
      # @return [Boolean]
      def stop_work?
        @stop || !source.next? || sink.stop?
      end

      # Job source
      #
      # @return [Source]
      def source
        config.source
      end

      # Job result sink
      #
      # @return [Sink]
      def sink
        config.sink
      end

    end # Master
  end # Parallel
end # Mutant
