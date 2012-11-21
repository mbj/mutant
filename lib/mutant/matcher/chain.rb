module Mutant
  class Matcher
    # A chain of matchers
    class Chain < self
      include Equalizer.new(:matchers)

      # Enumerate subjects
      #
      # @return [Enumerator<Subject]
      #   returns subject enumerator if no block given
      #
      # @return [self]
      #   returnns self otherwise
      #
      # @api private
      #
      def each(&block)
        return to_enum unless block_given?

        matchers.each do |matcher|
          matcher.each(&block)
        end

        self
      end

      # Return the chain of matchers
      #
      # @return [Enumerable<Chain>]
      #
      # @api private
      #
      attr_reader :matchers

      # Build matcher chain
      #
      # @param [Enumerable<Matcher>] matchers
      #
      # @return [Matcher]
      #
      # @api private
      #
      def self.build(matchers)
        if matchers.length == 1
          return matchers.first
        end

        new(matchers)
      end

    private

      # Initialize chain matcher
      #
      # @param [Enumerable<Matcher>] matchers
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(matchers)
        @matchers = matchers
      end
    end
  end
end
