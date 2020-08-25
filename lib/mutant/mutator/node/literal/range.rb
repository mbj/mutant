# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Literal

        # Abstract literal range mutator
        class Range < self

          MAP = {
            irange: :erange,
            erange: :irange
          }.freeze

          children :lower_bound, :upper_bound

          handle(*MAP.keys)

        private

          def dispatch
            emit_singletons
            emit_lower_bound_mutations

            return unless upper_bound

            emit_inverse
            emit_upper_bound_mutations
          end

          def emit_inverse
            emit(s(MAP.fetch(node.type), *children))
          end

        end # Range
      end # Literal
    end # Node
  end # Mutator
end # Mutant
