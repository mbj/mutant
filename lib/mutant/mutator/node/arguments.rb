# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Mutator for arguments node
      class Arguments < self

        handle(:args)

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          emit_argument_presence
          emit_argument_mutations
          emit_mlhs_expansion
        end

        # Emit argument presence mutation
        #
        # @return [undefined]
        def emit_argument_presence
          emit_type

          Util::Array::Presence.call(children).each do |children|
            if children.one? && n_mlhs?(Mutant::Util.one(children))
              emit_procarg(Mutant::Util.one(children))
            else
              emit_type(*children)
            end
          end
        end

        # Emit procarg form
        #
        # @return [undefined]
        def emit_procarg(arg)
          emit_type(s(:procarg0, *arg))
        end

        # Emit argument mutations
        #
        # @return [undefined]
        def emit_argument_mutations
          children.each_with_index do |child, index|
            Mutator.mutate(child).each do |mutant|
              next if invalid_argument_replacement?(mutant, index)
              emit_child_update(index, mutant)
            end
          end
        end

        # Test if child mutation is allowed
        #
        # @param [Parser::AST::Node]
        #
        # @return [Boolean]
        def invalid_argument_replacement?(mutant, index)
          n_arg?(mutant) && children[0...index].any?(&method(:n_optarg?))
        end

        # Emit mlhs expansions
        #
        # @return [undefined]
        def emit_mlhs_expansion
          mlhs_childs_with_index.each do |child, index|
            dup_children = children.dup
            dup_children.delete_at(index)
            dup_children.insert(index, *child)
            emit_type(*dup_children)
          end
        end

        # Multiple left hand side childs
        #
        # @return [Enumerable<Parser::AST::Node, Integer>]
        def mlhs_childs_with_index
          children.each_with_index.select do |child, _index|
            n_mlhs?(child)
          end
        end

      end # Arguments
    end # Node
  end # Mutator
end # Mutant
