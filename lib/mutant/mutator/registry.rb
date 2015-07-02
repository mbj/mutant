module Mutant
  class Mutator
    # Registry for mutators
    class Registry

      # Initialize object
      #
      # @return [undefined]
      #
      # @api private
      def initialize
        @registry = {}
      end

      # Raised when the type is an invalid type
      RegistryError = Class.new(TypeError)

      # Register mutator class for AST node class
      #
      # @param [Symbol] type
      # @param [Class:Mutator] mutator
      #
      # @return [self]
      #
      # @api private
      def register(type, mutator)
        fail RegistryError, "Invalid type registration: #{type}" unless AST::Types::ALL.include?(type)
        fail RegistryError, "Duplicate type registration: #{type}" if @registry.key?(type)
        @registry[type] = mutator
        self
      end

      # Lookup mutator class for node
      #
      # @param [Parser::AST::Node] node
      #
      # @return [Class]
      #
      # @raise [ArgumentError]
      #   raises argument error when mutator class cannot be found
      #
      # @api private
      def lookup(node)
        type = node.type
        @registry.fetch(type) do
          fail RegistryError, "No mutator to handle: #{type.inspect}"
        end
      end

    end # Registry

    REGISTRY = Registry.new

  end # Mutator
end # Mutant
