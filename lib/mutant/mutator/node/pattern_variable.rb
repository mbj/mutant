module Mutant
  class Mutator
    class Node
      # Mutator for pattern variable
      class PatternVariable < self

        handle(Rubinius::AST::PatternVariable)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_attribute_mutations(:name)
        end
      end
    end
  end
end
