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
          def dispatch
            emit_singletons
            emit_values(values)
            emit_special_cases
          end

          SPECIAL = [
            N_NAN,
            N_NEGATIVE_INFINITY,
            N_INFINITY
          ].freeze

          # Emit special cases
          #
          # @return [undefined]
          #
          # @api private
          def emit_special_cases
            SPECIAL.each(&method(:emit))
          end

          # Return values to test against
          #
          # @return [Array]
          #
          # @api private
          def values
            original = children.first
            # Work around a bug in RBX/MRI or JRUBY:
            [0.0, 1.0, -original].delete_if do |value|
              value.eql?(original)
            end
          end

        end # Float
      end # Literal
    end # Node
  end # Mutator
end # Mutant
