module Mutant
  class Mutator
    class Node
      class Send

        # Mutator for sends that correspond to a binary operator
        class BinaryOperatorMethod < Node

        private

          # Emit mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            emit_left_mutations
            emit_right_mutations
            emit(right)
          end

          # Emit left mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_left_mutations
            emit_attribute_mutations(:receiver)
          end

          # Return right
          #
          # @return [Parser::AST::Node]
          #
          # @api private
          #
          def right
            node.arguments.array.first
          end

          # Emit right mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def emit_right_mutations
            Mutator.each(right).each do |mutated|
              dup = dup_node
              dup.arguments.array[0] = mutated
              emit(dup)
            end
          end

        end # BinaryOperatorMethod

      end # Send
    end # Node
  end # Mutator
end # Mutant
