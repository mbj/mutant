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
      #   oherwise
      #
      # @api private
      #
      def each
        return to_enum unless block_given?

        matcher.each do |subject|
          next if filter.match?(subject)
          yield matcher
        end

        self
      end

    end # Filter
  end
end # Mutant
