# encoding: utf-8

module Mutant
  class Matcher
    # Matcher filter
    class Filter < self
      include Concord.new(:matcher, :filter)

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
      def each
        return to_enum unless block_given?

        matcher.each do |subject|
          next if filter.match?(subject)
          yield subject
        end

        self
      end

    end # Filter
  end # Matcher
end # Mutant
