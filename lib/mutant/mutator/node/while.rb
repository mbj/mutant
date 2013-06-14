module Mutant
  class Mutator
    class Node

      # Mutator for while expressions
      class While < self

        handle(:while)

        CONDITION_INDEX, BODY_INDEX = 0, 1

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          mutate_child(CONDITION_INDEX)
          mutate_child(BODY_INDEX)
        end

      end # While
    end # Node
  end # Mutator
end # Mutant
