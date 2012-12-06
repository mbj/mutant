module Mutant
  class Mutator
    class Node
      # Mutator on AST blocks
      class Block < self

        handle(Rubinius::AST::Block)

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          array = input.array
          emit_attribute_mutations(:array)
        end
      end
    end
  end
end
