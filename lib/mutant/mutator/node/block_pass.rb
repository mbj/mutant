module Mutant
  class Mutator
    class Node

      # Mutation emitter to handle block_pass nodes
      class BlockPass < self

        handle(:block_pass)

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

      end # BlockPass
    end # Node
  end # Mutator
end # Mutant
