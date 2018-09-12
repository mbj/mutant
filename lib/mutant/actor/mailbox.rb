# frozen_string_literal: true

module Mutant
  module Actor
    # Unbound mailbox
    class Mailbox
      include Adamantium::Flat, Concord::Public.new(:receiver, :sender)

      # New mailbox
      #
      # @return [Mailbox]
      def self.new
        mutex              = Mutex.new
        condition_variable = ConditionVariable.new
        messages           = []

        super(
          Receiver.new(condition_variable, mutex, messages),
          Sender.new(condition_variable, mutex, messages)
        )
      end

      # Binding for RPC to other actors
      #
      # @param [Actor::Sender] other
      #
      # @return [Binding]
      def bind(other)
        Binding.new(self, other)
      end

    end # Mailbox
  end # Actor
end # Mutant
