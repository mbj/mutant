module Mutant
  module Actor
    # Receiver side of an actor
    class Receiver
      include Adamantium::Flat, Concord.new(:condition_variable, :mutex, :messages)

      # Receives a message, blocking
      #
      # @return [Object]
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
      def try_blocking_receive
        mutex.synchronize do
          if messages.empty?
            condition_variable.wait(mutex)
            Undefined
          else
            messages.shift
          end
        end
      end

    end # Receiver
  end # Actor
end # Mutant
