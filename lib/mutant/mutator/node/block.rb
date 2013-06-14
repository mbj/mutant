module Mutant
  class Mutator
    class Node
      # Emitter for mutations on 19 blocks
      class Block < self

        handle(:block)

        SEND_INDEX, ARGUMENTS_INDEX, BODY_INDEX = 0, 1, 2

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit(children[SEND_INDEX])
          mutate_child(SEND_INDEX)
          mutate_child(ARGUMENTS_INDEX)
          mutate_child(BODY_INDEX)
        end

      end # Block
    end # Node
  end # Mutator
end # Mutant
