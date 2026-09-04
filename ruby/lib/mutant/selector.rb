# frozen_string_literal: true

module Mutant
  # Abstract base class for test selectors
  class Selector
    include AbstractType, Adamantium

    # Tests for subject
    #
    # @param [Subject] subjecto
    #
    # @return [Enumerable<Test>]
    abstract_method :call

    # Name of the strategy this selector implements
    #
    # @return [String]
    abstract_method :name

  end # Selector
end # Mutant
