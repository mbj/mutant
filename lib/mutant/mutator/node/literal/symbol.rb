module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for symbol literals
        class Symbol < self

          handle(:sym)

          PREFIX = 's'

        private

          # Emit mutatns
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            emit_nil
            emit_new { new_self((PREFIX + Random.hex_string).to_sym) }
          end

        end # Symbol
      end # Literal
    end # Node
  end # Mutator
end # Mutant
