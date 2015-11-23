module Mutant
  class Mutator
    class Node

      # Mutator for super with parentheses
      class Super < self

        handle(:super)

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          emit_singletons
          emit(N_EMPTY_SUPER)
          children.each_index do |index|
            mutate_child(index)
            delete_child(index)
          end
        end

      end # Super
    end # Node
  end # Mutator
end # Mutant
