module Mutant
  class Mutator
    class Node
      # Mutator for multiple assignment left hand side nodes
      class MLHS < self

        handle(:mlhs)

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          children.each_index do |index|
            mutate_child(index)
            delete_child(index) unless children.one?
          end
        end

      end # MLHS
    end # Node
  end # Mutator
end # Mutant
