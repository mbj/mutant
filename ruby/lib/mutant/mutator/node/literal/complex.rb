# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for complex literals
        class Complex < self

          ONE = 1i

          handle(:complex)

          children :value

        private

          def dispatch
            emit_singletons
            emit_values
          end

          def values
            [0i, ONE, value + ONE, value - ONE]
          end

        end # Complex
      end # Literal
    end # Node
  end # Mutator
end # Mutant
