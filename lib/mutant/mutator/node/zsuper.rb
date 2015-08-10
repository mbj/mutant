module Mutant
  class Mutator
    class Node

      # Mutator for super without parentheses
      class ZSuper < self

        handle(:zsuper)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        def dispatch
          emit_singletons
          emit(N_EMPTY_SUPER)
        end

      end # ZSuper
    end # Node
  end # Mutator
end # Mutant
