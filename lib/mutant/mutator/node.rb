module Mutant

  # Generator for mutations
  class Mutator

    # Abstract base class for node mutators
    class Node < self
      include AbstractType, Unparser::Constants
      include AST::NamedChildren, AST::NodePredicates, AST::Sexp, AST::Nodes

      # Helper to define a named child
      #
      # @param [Parser::AST::Node] node
      #
      # @param [Fixnum] index
      #
      # @return [undefined]
      #
      # @api private
      #
      def self.define_named_child(name, index)
        super

        define_method("emit_#{name}_mutations") do |&block|
          mutate_child(index, &block)
        end

        define_method("emit_#{name}") do |node|
          emit_child_update(index, node)
        end
      end
      private_class_method :children

    private

      # Return mutated node
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      alias_method :node, :input

      # Return duplicated node
      #
      # @return [Parser::AST::Node]
      #
      # @api private
      #
      alias_method :dup_node, :dup_input

      # Emit children mutations
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_children_mutations
        Mutator::Util::Array.each(children, self) do |children|
          emit_type(*children)
        end
      end

      # Return ast meta description
      #
      # @return [AST::Meta]
      #
      def meta
        AST::Meta.for(node)
      end
      memoize :meta

      # Return children
      #
      # @return [Array<Parser::AST::Node>]
      #
      # @api private
      #
      def children
        node.children
      end

      # Dispatch on child index
      #
      # @param [Fixnum] index
      #
      # @return [undefined]
      #
      # @api private
      #
      def mutate_child(index, mutator = Mutator, &block)
        block ||= ->(_node) { true }
        child = children.at(index)
        mutator.each(child, self) do |mutation|
          next unless block.call(mutation)
          emit_child_update(index, mutation)
        end
      end

      # Emit delete child mutation
      #
      # @param [Fixnum] index
      #
      # @return [undefined]
      #
      # @api private
      #
      def delete_child(index)
        dup_children = children.dup
        dup_children.delete_at(index)
        emit_type(*dup_children)
      end

      # Emit updated child
      #
      # @param [Fixnum] index
      # @param [Parser::AST::Node] node
      #
      # @return [undefined]
      #
      # @api private
      #
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
      #
      # @api private
      #
      def emit_type(*children)
        emit(Parser::AST::Node.new(node.type, children))
      end

      # Emit singleton literals
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_singletons
        emit_nil
        emit_self
      end

      # Emit a literal self
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_self
        emit(N_SELF)
      end

      # Emit a literal nil
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_nil
        emit(N_NIL) unless asgn_left?
      end

      # Emit values
      #
      # @param [Array<Object>] values
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_values(values)
        values.each do |value|
          emit_type(value)
        end
      end

      # Return parent node
      #
      # @return [Parser::AST::Node] node
      #   if parent with node is presnet
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def parent_node
        parent.node if parent
      end

      # Return parent type
      #
      # @return [Symbol] type
      #   if parent with type is presnet
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def parent_type
        parent_node.type if parent_node
      end

      # Test if the node is the left of an or_asgn or op_asgn
      #
      # @return [Boolean]
      #
      # @api private
      #
      def asgn_left?
        AST::Types::OP_ASSIGN.include?(parent_type) && parent.node.children.first.equal?(node)
      end

    end # Node
  end # Mutator
end # Mutant
