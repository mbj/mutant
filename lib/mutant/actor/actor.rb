module Mutant
  module Actor
    # Actor object available to acting threads
    class Actor
      include Concord.new(:thread, :mailbox)

      # Initialize object
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(*)
        super
        @sender = mailbox.sender(thread)
      end

      # Return sender to this actor
      #
      # @return [Sender]
      #
      # @api private
      #
      attr_reader :sender

      # Return receiver for messages to this actor
      #
      # @return [Receiver]
      #
      # @api private
      #
      def receiver
        mailbox.receiver
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

    end # Actor
  end # Actor
end # Mutant
