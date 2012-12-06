module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for float literals
        class Float < self

          handle(Rubinius::AST::FloatLiteral)

        private

          # Emit mutants
          #
          # @return [undefined]
          #
          def dispatch
            emit_nil
            emit_values(values)
            emit_special_cases
            emit_new { new_self(Random.float) }
          end

          # Emit special cases
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_special_cases
            [infinity, negative_infinity, nan].each do |value|
              emit(value)
            end
          end

          # Return values to test against
          #
          # @return [Array]
          #
          # @api private
          #
          def values
            [0.0, 1.0] << -node.value
          end
        end
      end
    end
  end
end
