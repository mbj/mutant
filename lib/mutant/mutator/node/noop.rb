module Mutant
  class Mutator
    class Node

      # Mutation emitter to handle noop nodes
      class Noop < self

        handle(:block_pass, :cbase)

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          # noop
        end

      end # Noop
    end # Node
  end # Mutator
end # Mutant
