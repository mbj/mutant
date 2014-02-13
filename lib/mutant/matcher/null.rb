# encoding: utf-8

module Mutant
  class Matcher
    # A null matcher, that does not match any subjects
    class Null < self
      include Equalizer.new

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
        self
      end

    end # Null
  end # Matcher
end # Mutant
