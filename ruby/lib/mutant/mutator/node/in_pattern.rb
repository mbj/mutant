# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutator for in pattern clauses
      class InPattern < self

        handle(:in_pattern)

        children :pattern, :guard, :body

      private

        def dispatch
          emit_pattern_mutations
          emit_guard_mutations if guard
          emit_body_mutations if body
        end

      end # InPattern
    end # Node
  end # Mutator
end # Mutant
