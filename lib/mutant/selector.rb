module Mutant
  # Abstract base class for test selectors
  class Selector
    include AbstractType, Adamantium::Flat

    # Return tests for subject
    #
    # @param [Subject] subjecto
    #
    # @return [Enumerable<Test>]
    #
    # @api private
    abstract_method :call

  end # Selector
end # Mutant
