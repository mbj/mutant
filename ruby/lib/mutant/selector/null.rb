# frozen_string_literal: true

module Mutant
  class Selector
    # Selector that never returns tests
    class Null < self
      include Equalizer.new

      # Name of the strategy this selector implements
      #
      # @return [String]
      def name = 'null'

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
