# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for integer literals
        class Integer < self

          handle(:int)

          children :value

        private

          def dispatch
            emit_singletons
            emit_values
          end

          def values
            [0, 1, value + 1, value - 1]
          end

        end # Integer
      end # Literal
    end # Node
  end # Mutator
end # Mutant
