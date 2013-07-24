module Mutant
  class Mutator
    class Node

      # Mutation emitter to handle cbase nodes
      class Cbase < self

        handle(:cbase)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          # noop, for now
        end

      end # Cbase
    end # Node
  end # Mutator
end # Mutant
