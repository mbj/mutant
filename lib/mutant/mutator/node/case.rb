module Mutant
  class Mutator
    class Node

      # Mutator for case nodes
      class Case < self

        handle(:case)

        CONDITION_INDEX = 0

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          mutate_child(CONDITION_INDEX)
          emit_branch_mutations
        end

        # Emit presence mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_branch_mutations
          children.each_with_index.drop(1).each do |child, index|
            next unless child
            mutate_index(index)
          end
        end

        # Perform mutations of child index
        #
        # @param [Fixnum] index
        #
        # @return [undefined]
        #
        # @api private
        #
        def mutate_index(index)
          mutate_child(index)
          dup_children = children.dup
          dup_children.delete_at(index)
          if dup_children.last.type == :when
            dup_children << nil
          end
          emit_self(*dup_children)
        end

      end # Case
    end # Node
  end # Mutator
end # Mutant
