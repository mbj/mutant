module Mutant
  class Mutator
    class Node
      class Send

        # Mutator for sends that correspond to a binary operator
        class Binary < self

          children :left, :operator, :right

        private

          # Emit mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            emit(left)
            emit_left_mutations
            emit(right)
            emit_right_mutations
          end

        end # Binary

      end # Send
    end # Node
  end # Mutator
end # Mutant
