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
          #
          # @api private
          def dispatch
            emit_singletons
            emit_values(values)
          end

          # Values to mutate to
          #
          # @return [Array]
          #
          # @api private
          def values
            [0, 1, -value, value + 1, value - 1]
          end

          # Literal original value
          #
          # @return [Object]
          #
          # @api private
          def value
            children.first
          end

        end # Fixnum
      end # Literal
    end # Node
  end # Mutator
end # Mutant
