# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutator for pattern alternation nodes
      class MatchAlt < self

        handle(:match_alt)

        children :left, :right

      private

        def dispatch
          emit(left)
          emit(right)
          emit_left_mutations
          emit_right_mutations
        end

      end # MatchAlt
    end # Node
  end # Mutator
end # Mutant
