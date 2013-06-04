module Mutant
  class Mutator
    # Registry for mutators
    module Registry
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

      # Register mutator class for AST node class
      #
      # @param [Class] ast_class
      # @param [Class] mutator_class
      #
      # @api private
      #
      # @return [self]
      #
      def self.register(ast_class,mutator_class)
        registry[ast_class]=mutator_class
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
          raise ArgumentError,"No mutator to handle: #{type.inspect}"
        end
      end
    end
  end
end
