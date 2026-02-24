# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutator for `expr in pattern` predicate nodes
      class MatchPatternP < self

        handle(:match_pattern_p)

        children :expression, :pattern

      private

        def dispatch
          emit(N_FALSE)
          emit_expression_mutations
          emit_pattern_mutations
        end

      end # MatchPatternP
    end # Node
  end # Mutator
end # Mutant
