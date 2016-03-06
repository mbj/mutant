module Mutant
  class Mutator
    class Node

      # Dsym mutator
      class Dsym < Generic

        handle(:dsym)

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          super()
          emit_singletons
        end

      end # Dsym
    end # Node
  end # Mutator
end # Mutant
