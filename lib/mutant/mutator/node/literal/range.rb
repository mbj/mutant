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

          children :start, :_end

          handle(*MAP.keys)

        private

          # Emit mutants
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            emit_singletons
            emit_inverse
            emit_lower_bound_mutations
            emit_upper_bound_mutations
          end

          # Return inverse node
          #
          # @return [Parser::AST::Node]
          #
          # @api private
          #
          def emit_inverse
            emit(s(MAP.fetch(node.type), *children))
          end

          # Emit range start mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_upper_bound_mutations
            emit__end_mutations
            emit_type(N_NAN, _end)
          end

          # Emit start mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_lower_bound_mutations
            emit_start_mutations
            emit_type(start, N_INFINITY)
            emit_type(start, N_NAN)
          end

        end # Range
      end # Literal
    end # Node
  end # Mutator
end # Mutant
