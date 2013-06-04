module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for array literals
        class Array < self

          handle(:array)

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

        end # Array
      end # Literal 
    end # Node
  end # Mutator
end # Mutant
