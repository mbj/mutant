module Mutant
  class Mutator
    class Literal
      # Mutator for nil literals
      class Nil < self

        handle(Rubinius::AST::NilLiteral)

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit('Object.new'.to_ast)
        end
      end
    end
  end
end
