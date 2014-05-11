# encoding: utf-8

module Mutant
  class Mutation
    # Neutral mutation
    class Neutral < self

      SYMBOL      = 'neutral'.freeze
      SHOULD_FAIL = false

      # Noop mutation, special case of neutral
      class Noop < self

        SYMBOL = 'noop'.freeze

      end # Noop

      # Return identification
      #
      # @return [String]
      #
      # @api private
      #
      def identification
        "#{self.class::SYMBOL}:#{super}"
      end
      memoize :identification

    end # Neutral
  end # Mutation
end # Mutant
