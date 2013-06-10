module Mutant
  class Mutator
    class Node

      # Namespace for send mutators
      class Send < self

        handle(:send)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
        end

      end # Send
    end # Node
  end # Mutator
end # Mutant
