module Mutant
  # A minimal actor implementation
  module Actor

    # Error raised when actor signalling protocol is violated
    class ProtocolError < RuntimeError
    end # ProtocolError

    # Undefined message payload
    Undefined = Class.new do
      INSPECT = 'Mutant::Actor::Undefined'.freeze

      # Return object inspection
      #
      # @return [String]
      #
      # @api private
      #
      def inspect
        INSPECT
      end
    end.new

    # Message being exchanged between actors
    class Message
      include Concord::Public.new(:type, :payload)

      # Return new message
      #
      # @param [Symbol] type
      # @param [Object] payload
      #
      # @return [Message]
      #
      def self.new(_type, _payload = Undefined)
        super
      end

    end # Message

    # Bindin to others actors sender for simple RPC
    class Binding
      include Concord.new(:actor, :other)

      # Send message and wait for reply
      #
      # @param [Symbol] type
      #
      # @return [Object]
      #
      def call(type)
        other.call(Message.new(type, actor.sender))
        message = actor.receiver.call
        fail ProtocolError, "Expected #{type} but got #{message.type}" unless type.equal?(message.type)
        message.payload
      end

    end # Binding
  end # Actor
end # Mutant
