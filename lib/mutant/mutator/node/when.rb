module Mutant
  class Mutator
    class Node

      # Mutator for Rubinius::AST::When nodes
      class When < self

        handle(Rubinius::AST::When)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_attribute_mutations(:body)
        end

      end
    end
  end
end
