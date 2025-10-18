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

  end # Selector
end # Mutant
