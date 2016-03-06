module Mutant
  class Mutator
    # Registry for mutators
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

      # Register mutator class for AST node class
      #
      # @param [Symbol] type
      # @param [Class:Mutator] mutator
      #
      # @return [self]
      def register(type, mutator)
        fail RegistryError, "Invalid type registration: #{type.inspect}" unless AST::Types::ALL.include?(type)
        fail RegistryError, "Duplicate type registration: #{type.inspect}" if contents.key?(type)
        contents[type] = mutator
        self
      end

      # Call registry
      #
      # @return [Enumerable<Mutation>]
      def call(node, parent = nil)
        lookup(node.type).call(node, parent)
      end

    private

      # Lookup mutator class for node
      #
      # @param [Symbol] type
      #
      # @return [Class]
      #
      # @raise [ArgumentError]
      #   raises argument error when mutator class cannot be found
      def lookup(type)
        contents.fetch(type) do
          fail RegistryError, "No mutator to handle: #{type.inspect}"
        end
      end

    end # Registry

    REGISTRY = Registry.new

  end # Mutator
end # Mutant
