module Mutant
  class Mutator
    class Node

      # Mutator for when nodes
      class When < self

        handle(:when)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_attribute_mutations(:body)
        end

      end # When
    end # Node
  end # Mutator
end # Mutant
