module Mutant
  module Actor
    # Receiver side of an actor
    class Receiver
      include Concord.new(:mutex, :mailbox)

      # Receives a message, blocking
      #
      # @return [Object]
      #
      # @api private
      #
      def call
        2.times do
          message = try_blocking_receive
          return message unless message.equal?(Undefined)
        end
        fail ProtocolError
      end

    private

      # Try a blocking receive
      #
      # @return [Undefined]
      #   if there is no message yet
      #
      # @return [Object]
      #   if there is a message
      #
      # @api private
      #
      def try_blocking_receive
        @mutex.lock
        if @mailbox.empty?
          @mutex.unlock
          Thread.stop
          Undefined
        else
          @mailbox.shift.tap do
            @mutex.unlock
          end
        end
      end

    end # Receiver
  end # Actor
end # Mutant
