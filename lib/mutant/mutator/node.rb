module Mutant

  # Generator for mutations
  class Mutator

    # Abstract base class for node mutators
    class Node < self
      include AbstractType, Unparser::Constants
      include AST::NamedChildren, AST::NodePredicates, AST::Sexp, AST::Nodes

      TAUTOLOGY = ->(_input) { true }

      # Helper to define a named child
      #
      # @param [Parser::AST::Node] node
      #
      # @param [Integer] index
      #
      # @return [undefined]
      def self.define_named_child(name, index)
        super

        define_method(:"emit_#{name}_mutations") do |&block|
          mutate_child(index, &block)
        end

        define_method(:"emit_#{name}") do |node|
          emit_child_update(index, node)
        end
      end
      private_class_method :define_named_child

    private

      # Node to mutate
      #
      # @return [Parser::AST::Node]
      alias_method :node, :input

      # Duplicate of original
      #
      # @return [Parser::AST::Node]
      alias_method :dup_node, :dup_input

      # Original nodes children
      #
      # @return [Array<Parser::AST::Node>]
      def children
        node.children
      end

      # Dispatch on child index
      #
      # @param [Integer] index
      #
      # @return [undefined]
      def mutate_child(index, &block)
        block ||= TAUTOLOGY
        Mutator.mutate(children.fetch(index), self).each do |mutation|
          next unless block.call(mutation)
          emit_child_update(index, mutation)
        end
      end

      # Emit delete child mutation
      #
      # @param [Integer] index
      #
      # @return [undefined]
      def delete_child(index)
        dup_children = children.dup
        dup_children.delete_at(index)
        emit_type(*dup_children)
      end

      # Emit updated child
      #
      # @param [Integer] index
      # @param [Parser::AST::Node] node
      #
      # @return [undefined]
      def emit_child_update(index, node)
        new_children = children.dup
        new_children[index] = node
        emit_type(*new_children)
      end

      # Emit a new AST node with same class as wrapped node
      #
      # @param [Array<Parser::AST::Node>] children
      #
      # @return [undefined]
      def emit_type(*children)
        emit(::Parser::AST::Node.new(node.type, children))
      end

      # Emit singleton literals
      #
      # @return [undefined]
      def emit_singletons
        emit_nil
        emit_self
      end

      # Emit a literal self
      #
      # @return [undefined]
      def emit_self
        emit(N_SELF)
      end

      # Emit a literal nil
      #
      # @return [undefined]
      def emit_nil
        emit(N_NIL) unless asgn_left?
      end

      # Parent node
      #
      # @return [Parser::AST::Node] node
      #   if parent with node is present
      #
      # @return [nil]
      #   otherwise
      def parent_node
        parent.node if parent
      end

      # Parent type
      #
      # @return [Symbol] type
      #   if parent with type is present
      #
      # @return [nil]
      #   otherwise
      def parent_type
        parent_node.type if parent_node
      end

      # Test if the node is the left of an or_asgn or op_asgn
      #
      # @return [Boolean]
      def asgn_left?
        AST::Types::OP_ASSIGN.include?(parent_type) && parent.node.children.first.equal?(node)
      end

      # Children indices
      #
      # @param [Range] range
      #
      # @return [Enumerable<Integer>]
      def children_indices(range)
        range.begin.upto(children.length + range.end)
      end

      # Emit single child mutation
      #
      # @return [undefined]
      def mutate_single_child
        children.each_with_index do |child, index|
          mutate_child(index)
          yield child, index unless children.one?
        end
      end

    end # Node
  end # Mutator
end # Mutant
