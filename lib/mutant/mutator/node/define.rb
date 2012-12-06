module Mutant
  class Mutator
    class Node
      class Define < self

        handle(Rubinius::AST::Define)
        handle(Rubinius::AST::DefineSingleton)
        handle(Rubinius::AST::DefineSingletonScope)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_body_mutations
        end
      end
    end
  end
end
