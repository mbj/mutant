# encoding: utf-8

module Mutant
  class Mutator
    class Node
      # Mutator for arguments node
      class Arguments < self

        handle(:args)

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_argument_presence
          emit_argument_mutations
          emit_mlhs_expansion
        end

        # Emit argument presence mutation
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_argument_presence
          emit_type
          Mutator::Util::Array::Presence.each(children, self) do |children|
            emit_type(*children)
          end
        end

        # Emit argument mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_argument_mutations
          children.each_with_index do |child, index|
            Mutator.each(child) do |mutant|
              unless invalid_argument_replacement?(mutant, index)
                emit_child_update(index, mutant)
              end
            end
          end
        end

        # Test if child mutation is allowed
        #
        # @param [Parser::AST::Node]
        #
        # @return [Boolean]
        #
        # @api private
        #
        def invalid_argument_replacement?(mutant, index)
          original = children.fetch(index)
          original.type.equal?(:optarg) &&
          mutant.type.equal?(:arg)      &&
          children[0...index].any? { |node| node.type.equal?(:optarg) }
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
            emit_type(*dup_children)
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
            child.type.equal?(:mlhs)
          end
        end

      end # Arguments
    end # Node
  end # Mutator
end # Mutant
