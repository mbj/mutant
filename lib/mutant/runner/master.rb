module Mutant
  class Runner
    # Master actor to control workers
    class Master
      include Concord.new(:env, :actor)

      private_class_method :new

      # Run master runner component
      #
      # @param [Env] env
      #
      # @return [Actor::Sender]
      #
      # @api private
      #
      def self.call(env)
        env.config.actor_env.spawn do |actor|
          new(env, actor).__send__(:run)
        end
      end

    private

      # Initialize object
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(*)
        super

        @scheduler = Scheduler.new(env)
        @workers   = env.config.jobs
        @stop      = false
        @stopping  = false
      end

      # Run work loop
      #
      # @return [self]
      #
      # @api private
      #
      def run
        @workers.times do |id|
          Worker.run(
            id:     id,
            config: env.config,
            parent: actor.sender
          )
        end

        receive_loop
      end

      # Handle messages
      #
      # @param [Actor::Message] message
      #
      # @return [undefined]
      #
      # @api private
      #
      def handle(message)
        type, payload = message.type, message.payload
        case type
        when :ready
          ready_worker(payload)
        when :status
          handle_status(payload)
        when :result
          handle_result(payload)
        when :stop
          handle_stop(payload)
        else
          fail Actor::ProtocolError, "Unexpected message: #{type.inspect}"
        end
      end

      # Run receive loop
      #
      # @return [undefined]
      #
      # @api private
      #
      def receive_loop
        loop do
          break if @workers.zero? && @stop
          handle(actor.receiver.call)
        end
      end

      # Handle status
      #
      # @param [Actor::Sender] sender
      #
      # @return [undefined]
      #
      # @api private
      #
      def handle_status(sender)
        sender.call(Actor::Message.new(:status, @scheduler.status))
      end

      # Handle result
      #
      # @param [JobResult] job_result
      #
      # @return [undefined]
      #
      # @api private
      #
      def handle_result(job_result)
        return if @stopping
        @scheduler.job_result(job_result)
        @stopping = env.config.fail_fast && @scheduler.status.done
      end

      # Handle stop
      #
      # @param [Actor::Sender] sender
      #
      # @return [undefined]
      #
      # @api private
      #
      def handle_stop(sender)
        @stopping = true
        @stop = true
        receive_loop
        sender.call(Actor::Message.new(:stop))
      end

      # Handle ready worker
      #
      # @param [Actor::Sender] sender
      #
      # @return [undefined]
      #
      # @api private
      #
      def ready_worker(sender)
        if @stopping
          stop_worker(sender)
          return
        end

        job = @scheduler.next_job

        if job
          sender.call(Actor::Message.new(:job, job))
        else
          stop_worker(sender)
        end
      end

      # Stop worker
      #
      # @param [Actor::Sender] sender
      #
      # @return [undefined]
      #
      # @api private
      #
      def stop_worker(sender)
        @workers -= 1
        sender.call(Actor::Message.new(:stop))
      end

    end # Master
  end # Runner
end # Mutant
