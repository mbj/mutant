module Mutant
  class Mutator
    class Node
      class MLHS < self

        handle(:mlhs)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          children.each_index do |index|
            mutate_child(index)
            delete_child(index)
          end
        end

      end # MLHS
    end # Node
  end # Mutator
end # Mutant
