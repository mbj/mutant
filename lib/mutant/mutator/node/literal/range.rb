module Mutant
  class Mutator
    class Node
      class Literal

        # Abstract literal range mutator
        class Range < self
          include AbstractType

          MAP = {
            :irange => :erange,
            :erange => :irange
          }.freeze

          START_INDEX, END_INDEX = 0, 1

          handle(*MAP.keys)

        private

          # Emit mutants
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            emit_nil
            emit_inverse
            emit_start_mutations
            emit_end_mutations
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
          def emit_end_mutations
            end_ = children[END_INDEX]
            #emit_self(negative_infinity, finish)
            emit_self(NAN, end_)
          end

          # Emit start mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_start_mutations
            start = children[START_INDEX]
            emit_self(start, INFINITY)
            emit_self(start, NAN)
          end

        end # Range
      end # Literal
    end # Node
  end # Mutator
end # Mutant
