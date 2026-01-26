# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Mutator for pattern match guard nodes (if_guard, unless_guard)
      class Guard < self
        handle(:if_guard, :unless_guard)

        children :condition

      private

        def dispatch
          emit_condition_mutations
          emit_type(N_TRUE)
          emit_type(N_FALSE)
        end

      end # Guard
    end # Node
  end # Mutator
end # Mutant
