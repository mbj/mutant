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
            emit(inverse)
          end

          # Return inverse
          #
          # @return [Rubinius::AST::Node]
          #
          # @api private
          #
          def inverse
            new(self.class::INVERSE_CLASS)
          end

          # Mutator for true literals
          class TrueLiteral < self
            INVERSE_CLASS = Rubinius::AST::FalseLiteral

            handle(Rubinius::AST::TrueLiteral)
          end


          # Mutator for false literals
          class FalseLiteral < self
            INVERSE_CLASS = Rubinius::AST::TrueLiteral

            handle(Rubinius::AST::FalseLiteral)
          end
        end
      end
    end
  end
end
