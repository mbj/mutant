# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutator for while expressions
      class ConditionalLoop < self

        INVERSE = {
          while: :until,
          until: :while
        }.freeze

        handle(*INVERSE.keys)

        children :condition, :body

      private

        def dispatch
          emit_singletons
          emit_condition_mutations
          emit_type_swap
          emit_body_mutations if body
          emit_body(nil)
          emit_body(N_RAISE)
        end

        def emit_type_swap
          emit(s(INVERSE.fetch(node.type), *children))
        end

      end # ConditionalLoop
    end # Node
  end # Mutator
end # Mutant
