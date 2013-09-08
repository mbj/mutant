# encoding: utf-8

module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for float literals
        class Float < self

          handle(:float)

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
            emit_special_cases
            emit_new { new_self(Random.float) }
          end

          SPECIAL = [
            NodeHelpers::NAN,
            NodeHelpers::NEGATIVE_INFINITY,
            NodeHelpers::INFINITY
          ].freeze

          # Emit special cases
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_special_cases
            SPECIAL.each do |value|
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
            [0.0, 1.0, -children.first]
          end

        end # Float
      end # Literal
    end # Node
  end # Mutator
end # Mutant
