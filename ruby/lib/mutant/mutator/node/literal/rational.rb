# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for rational literals
        class Rational < self

          ONE = 1r

          handle(:rational)

          children :value

        private

          def dispatch
            emit_singletons
            emit_values
          end

          def values
            [0r, ONE, value + ONE, value - ONE]
          end

        end # Rational
      end # Literal
    end # Node
  end # Mutator
end # Mutant
