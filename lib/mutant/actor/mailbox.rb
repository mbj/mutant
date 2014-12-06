module Mutant
  module Actor
    # Unbound mailbox
    class Mailbox
      include Adamantium::Flat, Concord::Public.new(:receiver, :sender)

      # Return new mailbox
      #
      # @return [Mailbox]
      #
      # @api private
      #
      def self.new
        mutex              = Mutex.new
        condition_variable = ConditionVariable.new
        messages           = []

        super(
          Receiver.new(condition_variable, mutex, messages),
          Sender.new(condition_variable, mutex, messages)
        )
      end

      # Return binding for RPC to other actors
      #
      # @param [Actor::Sender] other
      #
      # @return [Binding]
      #
      # @api private
      #
      def bind(other)
        Binding.new(self, other)
      end

    end # Mailbox
  end # Actor
end # Mutant
