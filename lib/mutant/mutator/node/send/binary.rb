module Mutant
  class Mutator
    class Node
      class Send

        # Mutator for sends that correspond to a binary operator
        class Binary < self

          RIGHT_INDEX = SELECTOR_INDEX+1

        private

          # Emit mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            emit(receiver)
            mutate_child(RECEIVER_INDEX) # left
            mutate_child(RIGHT_INDEX)
            emit(arguments.first)
          end

        end # Binary

      end # Send
    end # Node
  end # Mutator
end # Mutant
