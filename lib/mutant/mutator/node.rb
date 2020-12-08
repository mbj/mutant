# frozen_string_literal: true

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

      alias_method :node,     :input
      alias_method :dup_node, :dup_input

      def mutate_child(index, &block)
        block ||= TAUTOLOGY
        Mutator.mutate(children.fetch(index), self).each do |mutation|
          next unless block.call(mutation)
          emit_child_update(index, mutation)
        end
      end

      def delete_child(index)
        dup_children = children.dup
        dup_children.delete_at(index)
        emit_type(*dup_children)
      end

      def emit_child_update(index, node)
        new_children = children.dup
        new_children[index] = node
        emit_type(*new_children)
      end

      def emit_type(*children)
        emit(::Parser::AST::Node.new(node.type, children))
      end

      def emit_propagation(node)
        emit(node) unless AST::Types::NOT_STANDALONE.include?(node.type)
      end

      def emit_singletons
        emit_nil
        emit_self
      end

      def emit_self
        emit(N_SELF)
      end

      def emit_nil
        emit(N_NIL) unless left_op_assignment?
      end

      def parent_node
        parent&.node
      end

      def parent_type
        parent_node&.type
      end

      def left_op_assignment?
        AST::Types::OP_ASSIGN.include?(parent_type) && parent.node.children.first.equal?(node)
      end

      def children_indices(range)
        range.begin.upto(children.length + range.end)
      end

      def mutate_single_child
        children.each_with_index do |child, index|
          mutate_child(index)
          yield child, index unless children.one?
        end
      end

    end # Node
  end # Mutator
end # Mutant
