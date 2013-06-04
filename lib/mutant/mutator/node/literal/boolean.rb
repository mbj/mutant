module Mutant
  class Mutator
    class Node
      class Literal < self
        # Abstract mutator for boolean literals
        class Boolean < self

        private

          # Emit mutants
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            emit_nil
            emit(s(self.class::INVERSE_TYPE))
          end

          # Mutator for true literals
          class TrueLiteral < self
            INVERSE_TYPE = :false

            handle(:true)
          end


          # Mutator for false literals
          class FalseLiteral < self
            INVERSE_TYPE = :true

            handle(:false)
          end

        end # Boolean

      end # Literal
    end # Node
  end # Mutatork
end # Mutant
