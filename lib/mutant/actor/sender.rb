# frozen_string_literal: true

module Mutant
  module Actor

    # Sender for messages to acting thread
    class Sender
      include Adamantium::Flat, Concord.new(:condition_variable, :mutex, :messages)

      # Send a message to actor
      #
      # @param [Object] message
      #
      # @return [self]
      def call(message)
        mutex.synchronize do
          messages << message
          condition_variable.signal
        end

        self
      end

    end # Sender
  end # Actor
end # Mutant
