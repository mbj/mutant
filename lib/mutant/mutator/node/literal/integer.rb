# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for integer literals
        class Integer < self

          handle(:int)

        private

          # Emit mutations
          #
          # @return [undefined]
          def dispatch
            emit_singletons
            emit_values
          end

          # Values to mutate to
          #
          # @return [Array]
          def values
            [0, 1, -value, value + 1, value - 1]
          end

          # Literal original value
          #
          # @return [Object]
          def value
            value, = children
            value
          end

        end # Integer
      end # Literal
    end # Node
  end # Mutator
end # Mutant
