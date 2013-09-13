# encoding: utf-8

module Mutant
  class Predicate
    # Return matcher
    class Matcher < self
      include Concord.new(:matcher)

      # Test if subject matches
      #
      # @param [Subject] subject
      #
      # @return [true]
      #   if subject is handled by matcher
      #
      # @return [false]
      #   otherwise
      #
      def match?(subject)
        subjects.include?(subject)
      end

    private

      # Return subjects matched by matcher
      #
      # @return [Set<Subject>]
      #
      # @api private
      #
      def subjects
        matcher.to_a.to_set
      end
      memoize :subjects

    end # Matcher
  end # Predicate
end # Mutant
