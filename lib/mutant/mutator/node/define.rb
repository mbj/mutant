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
          emit_mutate_attributes(:body)
        end
      end
    end
  end
end
