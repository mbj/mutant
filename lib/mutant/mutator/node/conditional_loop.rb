module Mutant
  class Mutator
    class Node

      # Mutator for while expressions
      class ConditionalLoop < self

        handle(:until, :while)

        children :condition, :body

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          emit_singletons
          emit_condition_mutations
          emit_body_mutations if body
          emit_body(nil)
          emit_body(N_RAISE)
        end

      end # ConditionalLoop
    end # Node
  end # Mutator
end # Mutant
