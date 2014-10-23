module Mutant
  module Actor
    # Actor root environment
    class Env
      include Concord.new(:thread_root)

      # Spawn a new actor executing block
      #
      # @return [Actor::Sender]
      #
      # @api private
      #
      def spawn
        mailbox = Mailbox.new

        thread = thread_root.new do
          yield mailbox.actor(thread_root.current)
        end

        mailbox.sender(thread)
      end

      # Return an private actor for current thread
      #
      # @return [Actor::Private]
      #
      # @api private
      #
      def current
        Mailbox.new.actor(thread_root.current)
      end

    end # Env
  end # Actor
end # Mutant
