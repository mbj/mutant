module Mutant
  class Matcher
    # A chain of matchers
    class Chain < self
      include Concord::Public.new(:matchers)

      # Enumerate subjects
      #
      # @return [Enumerator<Subject]
      #   if no block given
      #
      # @return [self]
      #   otherwise
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

      # Build matcher chain
      #
      # @param [Enumerable<Matcher>] matchers
      #
      # @return [Matcher]
      #
      # @api private
      #
      def self.build(matchers)
        if matchers.length.equal?(1)
          return matchers.first
        end

        new(matchers)
      end

    end # Chain
  end # Matcher
end # Mutant
