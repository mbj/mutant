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
          #
          def dispatch
            emit_nil
            emit_values(values)
            emit_new { new_self(Random.fixnum) }
          end

          # Return values to mutate against
          #
          # @return [Array]
          #
          # @api private
          #
          def values
            [0, 1, -value, value + 1, value - 1]
          end

          # Return value
          #
          # @return [Object]
          #
          # @api private
          #
          def value
            children.first
          end

        end # Fixnuma
      end # Literal
    end # Node
  end # Mutator
end # Mutant
