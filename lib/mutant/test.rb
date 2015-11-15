module Mutant
  # Abstract base class for test that might kill a mutation
  class Test
    include Adamantium::Flat, Anima.new(
      :expression,
      :id
    )

    # Identification string
    #
    # @return [String]
    #
    # @api private
    alias_method :identification, :id

  end # Test
end # Mutant
