# frozen_string_literal: true

module Mutant
  # Abstract base class for test that might kill a mutation
  class Test
    include Anima.new(
      :expressions,
      :id,
      :location
    )

    # Identification string
    #
    # @return [String]
    alias_method :identification, :id

  end # Test
end # Mutant
