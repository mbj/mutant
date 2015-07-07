module Mutant
  class Mutator
    class Node
      class Literal
        # Mutator for string literals
        class String < self

          handle(:str)

        private

          # Emit mutants
          #
          # @return [undefined]
          #
          # @api private
          def dispatch
            emit_singletons
          end

        end # String
      end # Literal
    end # Node
  end # Mutator
end # Mutant
