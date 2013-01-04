module Mutant
  # Generator for mutations
  class Mutator
    # Abstract base class for node mutators
    class Node < self
      include AbstractType

      # Return identity of node
      #
      # @param [Rubinius::AST::Node] node
      #
      # @return [String]
      #
      # @api private
      #
      def self.identity(node)
        ToSource.to_source(node)
      end

    private

      # Return mutated node
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      alias_method :node, :input

      # Return duplicated node
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      alias_method :dup_node, :dup_input

      # Emit a new AST node
      #
      # @param [Rubinis::AST::Node:Class] node_class
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      def emit_node(node_class, *arguments)
        emit(new(node_class, *arguments))
      end

      # Create a new AST node with same class as wrapped node
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      def new_self(*arguments)
        new(node.class, *arguments)
      end

      # Create a new AST node with Rubnius::AST::NilLiteral class
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      def new_nil
        new(Rubinius::AST::NilLiteral)
      end

      # Create a new AST node with the same line as wrapped node
      #
      # @param [Class:Rubinius::AST::Node] node_class
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      def new(node_class, *arguments)
        node_class.new(node.line, *arguments)
      end

      # Emit a new AST node with same class as wrapped node
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_self(*arguments)
        emit(new_self(*arguments))
      end

      # Emit body mutations
      #
      # @param [Symbol] name
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_attribute_mutations(name, mutator = Mutator)
        value = node.public_send(name)

        mutator.each(value) do |mutation|
          dup = dup_node
          dup.public_send(:"#{name}=", mutation)
          yield dup if block_given?
          emit(dup)
        end
      end

      # Emit a new AST node with NilLiteral class
      #
      # @return [Rubinius::AST::NilLiteral]
      #
      # @api private
      #
      def emit_nil
        emit(new_nil)
      end

      # Return new Rubiinius::AST::SendWithArguments node
      #
      # @param [Rubnius::AST::Node] receiver
      # @param [Symbol] name
      # @param [Object] arguments
      #
      # @return [Rubinius::AST::SendWithArguments]
      #
      # @api private
      #
      def new_send_with_arguments(receiver, name, arguments)
        new(Rubinius::AST::SendWithArguments, receiver, name, arguments)
      end

      # Return AST representing send
      #
      # @param [Rubinius::AST::Node] receiver
      # @param [Symbol] name
      #
      # @return [Rubnius::AST::Send]
      #
      # @api private
      #
      def new_send(receiver, name)
        new(Rubinius::AST::Send, receiver, name)
      end

      # Return duplicated (unfrozen) node each call
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      alias_method :dup_node, :dup_input

    end
  end
end
