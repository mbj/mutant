module Mutant
  class Mutator
    class Literal < Mutator
      # Abstract mutator for boolean literals
      class Boolean < Literal

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_nil
          emit_safe(inverse)
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

        # Represent mutations of true literal
        class TrueLiteral < Boolean
          INVERSE_CLASS = Rubinius::AST::FalseLiteral

          handle(Rubinius::AST::TrueLiteral)
        end


        # Represent mutations of false literal
        class FalseLiteral < Boolean
          INVERSE_CLASS = Rubinius::AST::TrueLiteral

          handle(Rubinius::AST::FalseLiteral)
        end
      end
    end
  end
end
