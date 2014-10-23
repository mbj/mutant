module Mutant
  module Actor
    # Unbound mailbox
    class Mailbox

      # Initialize new unbound mailbox
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize
        @mutex    = Mutex.new
        @messages = []
        @receiver = Receiver.new(@mutex, @messages)
        freeze
      end

      # Return receiver
      #
      # @return [Receiver]
      #
      # @api private
      #
      attr_reader :receiver

      # Return actor that is able to read mailbox
      #
      # @param [Thread] thread
      #
      # @return [Actor]
      #
      # @api private
      #
      def actor(thread)
        Actor.new(thread, self)
      end

      # Return sender to mailbox
      #
      # @param [Thread] thread
      #
      # @return [Sender]
      #
      # @api private
      #
      def sender(thread)
        Sender.new(thread, @mutex, @messages)
      end

    end # Mailbox
  end # Actor
end # Mutant
