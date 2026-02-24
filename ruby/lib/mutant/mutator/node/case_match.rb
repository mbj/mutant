# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutator for case/in pattern matching nodes
      class CaseMatch < self

        handle(:case_match)

        children :condition

        define_named_child(:else_branch, -1)

        PATTERNS = (1..-2)

      private

        def dispatch
          emit_condition_mutations
          emit_in_pattern_mutations
          emit_else_mutations
        end

        def emit_in_pattern_mutations
          indices = children_indices(PATTERNS)
          one = indices.one?

          indices.each do |index|
            mutate_child(index)
            delete_child(index) unless one
          end
        end

        def emit_else_mutations
          return unless else_branch

          emit_else_branch_mutations
          emit_else_branch(nil)
        end

      end # CaseMatch
    end # Node
  end # Mutator
end # Mutant
