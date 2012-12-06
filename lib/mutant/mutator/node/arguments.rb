module Mutant
  class Mutator
    class Node
      # Mutator for arguments
      class Arguments < self

        handle(Rubinius::AST::ActualArguments)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_body_mutations(:array)
        end

      end
    end
  end
end
