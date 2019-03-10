# frozen_string_literal: true

module Mutant
  # Abstract base class for test selectors
  class Selector
    include AbstractType, Adamantium::Flat

    # Tests for subject
    #
    # @param [Subject] subject
    #
    # @return [Maybe<Enumerable<Test>>]
    abstract_method :call

  end # Selector
end # Mutant
