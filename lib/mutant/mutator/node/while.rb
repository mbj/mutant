module Mutant
  class Mutator
    class Node

      # Mutator for while expressions
      class While < self

        handle(:while)

        CONDITION_INDEX, BODY_INDEX = 0, 1

        children :condition, :body

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_condition_mutations
          emit_body_mutations
        end

      end # While
    end # Node
  end # Mutator
end # Mutant
