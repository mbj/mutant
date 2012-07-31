module Mutant
  class Mutator
    class Literal < Mutator
      # Represent mutations on fixnum literal
      class Float < Literal

        handle(Rubinius::AST::FloatLiteral)

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        def dispatch
          emit_nil
          emit_values(values)
          emit_safe(infinity)
          emit_safe(negative_infinity)
          emit_safe(nan)
          emit_new { new_self(Mutant.random_float) }
        end

        # Return values to test against
        #
        # @return [Array]
        #
        # @api private
        #
        def values
          [0.0, 1.0] << -node.value
        end
      end
    end
  end
end
