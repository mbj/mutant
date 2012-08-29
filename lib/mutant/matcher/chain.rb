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

        @matchers.each do |matcher|
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
      def matchers; @matchers; end

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
