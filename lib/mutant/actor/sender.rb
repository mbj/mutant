module Mutant
  module Actor

    # Sender for messages to acting thread
    class Sender
      include Concord.new(:thread, :mutex, :mailbox)

      # Send a message to actor
      #
      # @param [Object] message
      #
      # @return [self]
      #
      # @api private
      #
      def call(message)
        mutex.synchronize do
          mailbox << message
          thread.run
        end

        self
      end

    end # Sender
  end # Actor
end # Mutant
