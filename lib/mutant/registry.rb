# frozen_string_literal: true

module Mutant
  # Registry for mapping AST types to classes
  class Registry
    include Anima.new(:contents, :default)

    # Initialize object
    #
    # @return [undefined]
    def initialize(default)
      super(contents: {}, default: default)
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
    # @return [Class<Mutator>]
    def lookup(type)
      contents.fetch(type, &default)
    end

  end # Registry
end # Mutant
