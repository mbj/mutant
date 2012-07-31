module Mutant
  class Mutator
    class Literal
      # Represent mutations on string literal
      class String < Literal

        handle(Rubinius::AST::StringLiteral)

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_nil
          emit_new { new_self(Mutant.random_hex_string) }
        end
      end
    end
  end
end
