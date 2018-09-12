# frozen_string_literal: true

module Mutant
  # Registry for mapping AST types to classes
  class Registry
    include Concord.new(:contents)

    # Initialize object
    #
    # @return [undefined]
    def initialize
      super({})
    end

    # Raised when the type is an invalid type
    RegistryError = Class.new(TypeError)

    # Register class for AST node class
    #
    # @param [Symbol] type
    # @param [Class] class
    #
    # @return [self]
    def register(type, klass)
      fail RegistryError, "Invalid type registration: #{type.inspect}" unless AST::Types::ALL.include?(type)
      fail RegistryError, "Duplicate type registration: #{type.inspect}" if contents.key?(type)
      contents[type] = klass
      self
    end

    # Lookup class for node
    #
    # @param [Symbol] type
    #
    # @return [Class]
    #
    # @raise [ArgumentError]
    #   raises argument error when class cannot be found
    def lookup(type)
      contents.fetch(type) do
        fail RegistryError, "No entry for: #{type.inspect}"
      end
    end

  end # Registry
end # Mutant
