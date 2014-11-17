module Mutant
  class Mutator
    # Registry for mutators
    module Registry

      # Raised when the type is an invalid type
      InvalidTypeError = Class.new(TypeError)

      # Raised when the type is a duplicate
      DuplicateTypeError = Class.new(ArgumentError)

      # Register mutator class for AST node class
      #
      # @param [Symbol] type
      # @param [Class] mutator_class
      #
      # @api private
      #
      # @return [self]
      #
      def self.register(type, mutator_class)
        assert_valid_type(type)
        assert_unique_type(type)
        registry[type] = mutator_class
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
      #
      def self.lookup(node)
        type = node.type
        registry.fetch(type) do
          fail ArgumentError, "No mutator to handle: #{type.inspect}"
        end
      end

      # Return registry state
      #
      # @return [Hash]
      #
      # @api private
      #
      def self.registry
        @registry ||= {}
      end
      private_class_method :registry

      # Assert the node type is valid
      #
      # @param [Symbol] type
      #
      # @return [undefined]
      #
      # @raise [InvalidTypeError]
      #   raised when the node type is invalid
      #
      # @api private
      #
      def self.assert_valid_type(type)
        unless AST::Types::ALL.include?(type) || type.is_a?(Class)
          fail InvalidTypeError, "invalid type registration: #{type}"
        end
      end
      private_class_method :assert_valid_type

      # Assert the node type is unique and not already registered
      #
      # @return [undefined]
      #
      # @raise [DuplicateTypeError]
      #   raised when the node type is a duplicate
      #
      # @api private
      #
      def self.assert_unique_type(type)
        if registry.key?(type)
          fail DuplicateTypeError, "duplicate type registration: #{type}"
        end
      end
      private_class_method :assert_unique_type

    end # Registry
  end # Mutator
end # Mutant
