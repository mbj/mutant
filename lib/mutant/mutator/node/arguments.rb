# encoding: utf-8

module Mutant
  class Mutator
    class Node
      # Mutator for arguments node
      class Arguments < self

        handle(:args)

        UNDERSCORE = '_'.freeze

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_self if relevant_args_with_index.any?
          emit_relevant_args
          emit_mlhs_expansion
        end

        # Emit mutations for children not marked as irrelevant
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_relevant_args
          relevant_args_with_index.each do |_child, index|
            mutate_child(index)
            delete_child(index)
          end
        end

        # Return children not marked as irrelevant
        #
        # @return [Enumerable<Parser::AST::Node, Fixnum>]
        #
        # @api private
        #
        def relevant_args_with_index
          children.each_with_index.reject do |child, _index|
            name = child.children.first
            name.to_s.start_with?(UNDERSCORE)
          end
        end

        # Emit mlhs expansions
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_mlhs_expansion
          mlhs_childs_with_index.each do |child, index|
            dup_children = children.dup
            dup_children.delete_at(index)
            dup_children.insert(index, *child.children)
            emit_self(*dup_children)
          end
        end

        # Return mlhs childs
        #
        # @return [Enumerable<Parser::AST::Node, Fixnum>]
        #
        # @api private
        #
        def mlhs_childs_with_index
          children.each_with_index.select do |child, _index|
            child.type == :mlhs
          end
        end

      end # Arguments
    end # Node
  end # Mutator
end # Mutant
