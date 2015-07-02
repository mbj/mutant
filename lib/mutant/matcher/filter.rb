module Mutant
  class Matcher
    # Matcher filter
    class Filter < self
      include Concord.new(:matcher, :predicate)

      # Return new matcher
      #
      # @return [Matcher] matcher
      #
      # @return [Matcher]
      #
      # @api private
      #
      def self.build(matcher, &predicate)
        new(matcher, predicate)
      end

      # Enumerate matches
      #
      # @return [self]
      #   if block given
      #
      # @return [Enumerator<Subject>]
      #   otherwise
      #
      # @api private
      def each(&block)
        return to_enum unless block_given?
        matcher.select(&predicate.method(:call)).each(&block)
        self
      end

    end # Filter
  end # Matcher
end # Mutant
