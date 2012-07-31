module Mutant
  class Mutator
    class Literal < Mutator
      # Mutator for empty array literals
      class EmptyArray < Literal

        handle(Rubinius::AST::EmptyArray)

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_nil
          emit(Rubinius::AST::ArrayLiteral, [new_nil])
        end
      end
    end
  end
end
