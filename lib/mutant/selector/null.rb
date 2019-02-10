# frozen_string_literal: true

module Mutant
  class Selector
    # Selector that never returns tests
    class Null < self
      # Tests for subject
      #
      # @param [Subject] subject
      #
      # @return [Enumerable<Test>]
      def call(_subject)
        EMPTY_ARRAY
      end
    end # Null
  end # Selector
end # Mutant
