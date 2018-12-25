# frozen_string_literal: true

module Mutant
  # A minimal actor implementation
  module Actor

    # Error raised when actor signalling protocol is violated
    class ProtocolError < RuntimeError
    end # ProtocolError

    # Undefined message payload
    Undefined = Class.new do
      INSPECT = 'Mutant::Actor::Undefined'

      # Object inspection
      #
      # @return [String]
      def inspect
        INSPECT
      end
    end.new

    # Message being exchanged between actors
    class Message
      include Concord::Public.new(:type, :payload)

      # New message
      #
      # @param [Symbol] type
      # @param [Object] payload
      #
      # @return [Message]
      def self.new(_type, _payload = Undefined)
        super
      end

    end # Message

    # Binding to other actors sender for simple RPC
    class Binding
      include Concord.new(:mailbox, :other)

      # Send message and wait for reply
      #
      # @param [Symbol] type
      #
      # @return [Object]
      def call(type)
        other.call(Message.new(type, mailbox.sender))
        message = mailbox.receiver.call
        fail ProtocolError, "Expected #{type} but got #{message.type}" unless type.equal?(message.type)
        message.payload
      end

    end # Binding
  end # Actor
end # Mutant
