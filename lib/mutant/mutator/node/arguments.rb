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
          emit_argument_mutations
          emit_mlhs_expansion
          emit_procarg0_removal
        end

        def forward_type?(removed)
          n_forward_arg?(removed) || n_restarg?(removed) || n_kwrestarg?(removed)
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
            mutate(node: child).each do |mutant|
              next if invalid_argument_replacement?(mutant, index)
              emit_child_update(index, mutant)
            end
          end
        end

        def invalid_argument_replacement?(mutant, index)
          n_arg?(mutant) && children[...index].any?(&method(:n_optarg?))
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

        def emit_procarg0_removal
          return unless children.one? && n_procarg0?((procarg0 = Mutant::Util.one(children)))

          arguments = procarg0.children
          emit_type(*arguments) if arguments.count > 1
        end

      end # Arguments
    end # Node
  end # Mutator
end # Mutant
