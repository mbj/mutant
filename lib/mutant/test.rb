# frozen_string_literal: true

module Mutant
  # Abstract base class for test that might kill a mutation
  class Test
    include Adamantium::Flat, Anima.new(
      :expression,
      :id,
      :lineno,
      :path
    )

    # Identification string
    #
    # @return [String]
    alias_method :identification, :id

    # Trace location
    #
    # @return [String]
    def trace_location
      "#{path}:#{lineno}"
    end
    memoize :trace_location

    def <=>(other)
      id <=> other.id
    end

  end # Test
end # Mutant
