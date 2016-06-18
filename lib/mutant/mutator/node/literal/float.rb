module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for float literals
        class Float < self

          handle(:float)

        private

          # Emit mutations
          #
          # @return [undefined]
          def dispatch
            emit_singletons
            emit_values
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
          def emit_special_cases
            SPECIAL.each(&method(:emit))
          end

          # Values to mutate to
          #
          # @return [Array]
          def values
            original = children.first

            [0.0, 1.0, -original]
          end

        end # Float
      end # Literal
    end # Node
  end # Mutator
end # Mutant
