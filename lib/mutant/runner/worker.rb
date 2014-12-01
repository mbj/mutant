module Mutant
  class Runner
    # Mutation killing worker receiving work from parent
    class Worker
      include Adamantium::Flat, Anima.new(:config, :id, :parent)

      private_class_method :new

      # Run worker
      #
      # @param [Hash<Symbol, Object] attributes
      #
      # @return [Actor::Sender]
      #
      # @api private
      #
      def self.run(attributes)
        attributes.fetch(:config).actor_env.spawn do |actor|
          worker = new(attributes)
          worker.send(:run, actor)
        end
      end

    private

      # Worker loop
      #
      # @return [self]
      #
      # @api private
      #
      # rubocop:disable Lint/Loop
      #
      def run(actor)
        begin
          parent.call(Actor::Message.new(:ready, actor.sender))
        end until handle(actor.receiver.call)
      end

      # Handle job
      #
      # @param [Message] message
      #
      # @return [Boolean]
      #
      # @api private
      #
      def handle(message)
        type, payload = message.type, message.payload
        case message.type
        when :job
          handle_job(payload)
          nil
        when :stop
          true
        else
          fail Actor::ProtocolError, "Unknown command: #{type.inspect}"
        end
      end

      # Handle mutation
      #
      # @param [Job] job
      #
      # @return [undefined]
      #
      # @api private
      #
      def handle_job(job)
        parent.call(Actor::Message.new(:result, JobResult.new(job: job, result: run_mutation(job))))
      end

      # Run mutation
      #
      # @param [Mutation] mutation
      #
      # @return [Report::Mutation]
      #
      # @api private
      #
      def run_mutation(job)
        job.mutation.kill(config.isolation).update(
          index: job.index
        )
      end

    end # Worker
  end # Runner
end # Mutant
