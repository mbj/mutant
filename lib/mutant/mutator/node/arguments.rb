# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Mutator for arguments node
      class Arguments < self

        ANONYMOUS_BLOCKARG_PRED = ::Parser::AST::Node.new(:blockarg, [nil]).method(:eql?)

        handle(:args)

      private

        def dispatch
          emit_argument_presence
          emit_argument_mutations
          emit_mlhs_expansion
        end

        def emit_argument_presence
          emit_type unless removed_block_arg?(EMPTY_ARRAY) || forward_arg?

          children.each_with_index do |removed, index|
            new_arguments = children.dup
            new_arguments.delete_at(index)
            unless n_forward_arg?(removed) || removed_block_arg?(new_arguments) || only_mlhs?(new_arguments)
              emit_type(*new_arguments)
            end
          end
        end

        def only_mlhs?(new_arguments)
          new_arguments.one? && n_mlhs?(new_arguments.first)
        end

        def forward_arg?
          children.last && n_forward_arg?(children.last)
        end

        def removed_block_arg?(new_arguments)
          anonymous_block_arg? && new_arguments.none?(&ANONYMOUS_BLOCKARG_PRED)
        end

        def anonymous_block_arg?
          children.any?(&ANONYMOUS_BLOCKARG_PRED)
        end
        memoize :anonymous_block_arg?

        def emit_argument_mutations
          children.each_with_index do |child, index|
            Mutator.mutate(child).each do |mutant|
              next if invalid_argument_replacement?(mutant, index)
              emit_child_update(index, mutant)
            end
          end
        end

        def invalid_argument_replacement?(mutant, index)
          n_arg?(mutant) && children[0...index].any?(&method(:n_optarg?))
        end

        def emit_mlhs_expansion
          mlhs_childs_with_index.each do |child, index|
            dup_children = children.dup
            dup_children.delete_at(index)
            dup_children.insert(index, *child)
            emit_type(*dup_children)
          end
        end

        def mlhs_childs_with_index
          children.each_with_index.select do |child,|
            n_mlhs?(child)
          end
        end

      end # Arguments
    end # Node
  end # Mutator
end # Mutant
