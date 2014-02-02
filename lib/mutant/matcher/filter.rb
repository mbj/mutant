# encoding: utf-8

module Mutant
  class Matcher
    # Matcher filter
    class Filter < self
      include Concord.new(:matcher, :predicate)

      # Enumerate matches
      #
      # @return [self]
      #   if block given
      #
      # @return [Enumerator<Subject>]
      #   otherwise
      #
      # @api private
      #
      def each(&block)
        return to_enum unless block_given?
        matcher.select(&predicate.method(:call)).each(&block)
        self
      end

    end # Filter
  end # Matcher
end # Mutant
