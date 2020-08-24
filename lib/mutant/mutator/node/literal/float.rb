# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for float literals
        class Float < self

          handle(:float)

        private

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

          def emit_special_cases
            SPECIAL.each(&method(:emit))
          end

          def values
            original = children.first

            [0.0, 1.0, -original]
          end

        end # Float
      end # Literal
    end # Node
  end # Mutator
end # Mutant
