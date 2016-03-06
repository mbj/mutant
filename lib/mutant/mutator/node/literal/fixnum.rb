module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for fixnum literals
        class Fixnum < self

          handle(:int)

        private

          # Emit mutants
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
            children.first
          end

        end # Fixnum
      end # Literal
    end # Node
  end # Mutator
end # Mutant
