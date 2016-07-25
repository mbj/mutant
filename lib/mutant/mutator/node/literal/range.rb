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

          # Emit mutations
          #
          # @return [undefined]
          def dispatch
            emit_singletons
            emit_inverse
            emit_lower_bound_mutations
            emit_upper_bound_mutations
          end

          # Inverse node
          #
          # @return [Parser::AST::Node]
          def emit_inverse
            emit(s(MAP.fetch(node.type), *children))
          end

        end # Range
      end # Literal
    end # Node
  end # Mutator
end # Mutant
