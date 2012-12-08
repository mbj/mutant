module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for array literals
        class Array < self

          handle(Rubinius::AST::ArrayLiteral)

        private

          # Emit mutations
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            emit_attribute_mutations(:body)
            emit_self([])
            emit_nil
            emit_self([new_nil] + node.body.dup)
          end
        end
      end
    end
  end
end
