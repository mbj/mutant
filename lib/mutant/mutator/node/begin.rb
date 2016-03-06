module Mutant
  class Mutator
    class Node

      # Mutator for begin nodes
      class Begin < self

        handle(:begin)

      private

        # Emit mutants
        #
        # @return [undefined]
        def dispatch
          mutate_single_child do |child|
            emit(child)
          end
        end
      end # Block
    end # Node
  end # Mutator
end # Mutant
