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
        abstract :inverse

        # Represent mutations of true literal
        class TrueLiteral < Boolean

          handle(Rubinius::AST::TrueLiteral)
      
        private

          # Return inverse
          #
          # @return [Rubinius::AST::FalseLiteral]
          #
          # @api private
          #
          def inverse
            new(Rubinius::AST::FalseLiteral)
          end
        end


        # Represent mutations of false literal
        class FalseLiteral < Boolean

          handle(Rubinius::AST::FalseLiteral)
      
        private

          # Return inverse class
          #
          # @return [Rubinius::AST::TrueLiteral]
          #
          # @api private
          #
          def inverse
            new(Rubinius::AST::TrueLiteral)
          end
        end
      end
    end
  end
end
