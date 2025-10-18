# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Send

        # Mutator for sends that correspond to a binary operator
        class Binary < self

          children :left, :operator, :right

        private

          def dispatch
            emit(left)
            emit_left_mutations
            emit_selector_replacement
            emit(right)
            emit_right_mutations
            emit_not_equality_mutations
          end

          def emit_not_equality_mutations
            return unless operator.equal?(:'!=')

            emit_not_equality_mutation(:eql?)
            emit_not_equality_mutation(:equal?)
          end

          def emit_not_equality_mutation(new_operator)
            emit(n_not(s(:send, left, new_operator, right)))
          end

        end # Binary

      end # Send
    end # Node
  end # Mutator
end # Mutant
