module Mutant
  class Mutator
    class Node
      class Literal < self
        # Abstract mutator for boolean literals
        class Boolean < self

          handle :true, :false

        private

          MAP = {
            :true  => :false,
            :false => :true
          }.freeze

          # Emit mutants
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            emit_nil
            emit(s(MAP.fetch(node.type)))
          end

        end # Boolean
      end # Literal
    end # Node
  end # Mutatork
end # Mutant
