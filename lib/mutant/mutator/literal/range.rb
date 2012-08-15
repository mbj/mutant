module Mutant
  class Mutator
    class Literal
      # Abstract literal range mutator
      class Range < self
        include Abstract

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
          emit_finish_mutations
          emit_start_mutations
        end

        # Emit range start mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_finish_mutations
          finish = node.finish
          emit_self(negative_infinity, finish)
          emit_self(nan, finish)
        end

        # Emit start mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_start_mutations
          start = node.start
          emit_self(start, infinity)
          emit_self(start, nan)
        end

        # Return inverse AST node class
        #
        # @return [Class:Rubinius::AST::Node]
        #
        # @api private
        #
        def inverse_class
          self.class::INVERSE_CLASS
        end

        # Mutator for range exclude literals
        class Exclude < self
          INVERSE_CLASS = Rubinius::AST::Range
          handle(Rubinius::AST::RangeExclude)

        end

        # Mutator for range include literals
        class Include < self
          INVERSE_CLASS = Rubinius::AST::RangeExclude
          handle(Rubinius::AST::Range)
        end
      end
    end
  end
end
