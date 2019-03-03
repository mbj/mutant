# frozen_string_literal: true

module Mutant
  class Selector
    # Selector that never returns tests
    class Null < self
      include Equalizer.new

      # Tests for subject
      #
      # @param [Subject] subject
      #
      # @return [Maybe<Enumerable<Test>>]
      def call(_subject)
        Maybe::Just.new(EMPTY_ARRAY)
      end
    end # Null
  end # Selector
end # Mutant
