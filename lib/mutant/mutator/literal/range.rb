module Mutant
  class Mutator
    class Literal
      # Abstract literal range mutator
      class Range < Literal

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
          emit_range
        end

        # Return inverse node
        #
        # @return [Rubinius::AST::Node]
        #
        # @api private
        #
        def inverse
          new(inverse_class,node.start, node.finish)
        end

        # Emit range specific mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_range
          start, finish = node.start, node.finish
          emit_self(negative_infinity, finish)
          emit_self(nan, finish)
          emit_self(start, infinity)
          emit_self(start, nan)
        end

        # Return inverse AST node class
        #
        # @return [Class:Rubinius::AST::Node]
        #
        # @api private
        #
        abstract_method :inverse_class

        # Mutator for range exclude literals
        class Exclude < Range

          handle(Rubinius::AST::RangeExclude)

        private

          # Return inverse class
          #
          # @return [Class:Rubnius::AST::Range]
          #
          # @api private
          #
          def inverse_class
            Rubinius::AST::Range
          end
        end

        # Mutator for range literals
        class Include < Range

          handle(Rubinius::AST::Range)

        private

          # Return inverse class
          #
          # @return [Class:Rubnius::AST::RangeExclude]
          #
          # @api private
          #
          def inverse_class
            Rubinius::AST::RangeExclude
          end
        end
      end
    end
  end
end
