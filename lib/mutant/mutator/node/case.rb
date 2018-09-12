# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutator for case nodes
      class Case < self

        handle(:case)

        children :condition

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          emit_singletons
          emit_condition_mutations if condition
          emit_when_mutations
          emit_else_mutations
        end

        # Emit when mutations
        #
        # @return [undefined]
        def emit_when_mutations
          indices = children.each_index.drop(1).take(children.length - 2)
          one = indices.one?
          indices.each do |index|
            mutate_child(index)
            delete_child(index) unless one
          end
        end

        # Emit else mutations
        #
        # @return [undefined]
        def emit_else_mutations
          else_branch = children.last
          else_index = children.length - 1
          return unless else_branch
          mutate_child(else_index)
          emit_child_update(else_index, nil)
        end

      end # Case
    end # Node
  end # Mutator
end # Mutant
