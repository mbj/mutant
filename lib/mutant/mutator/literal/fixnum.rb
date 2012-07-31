module Mutant
  class Mutator
    class Literal < Mutator
      # Represent mutations on fixnum literal
      class Fixnum < Literal

        handle(Rubinius::AST::FixnumLiteral)

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_nil
          emit_values(values)
          emit_new { new_self(Mutant.random_fixnum) }
        end

        # Return values to mutate against
        #
        # @return [Array]
        #
        # @api private
        #
        def values
          [0, 1, -node.value]
        end
      end
    end
  end
end
