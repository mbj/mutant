module Mutant
  class Mutator
    class Node

      # Mutation emitter to handle multiple assignment nodes
      class MultipleAssignment < self

        handle(:masgn)

        children :left, :right

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          emit_singletons
          emit_left_mutations
        end

      end # MultipleAssignment
    end # Node
  end # Mutator
end # Mutant
