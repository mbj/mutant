module Mutant
  class Mutator
    class Node

      # Mutator for loop control keywords
      class Next < Generic

        handle(:next)

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          super()
          emit_singletons
          children.each_index(&method(:delete_child))
          emit(s(:break, *children))
        end

      end # Next
    end # Node
  end # Mutator
end # Mutant
