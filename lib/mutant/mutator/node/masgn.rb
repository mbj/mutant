module Mutant
  class Mutator
    class Node

      # Mutation emitter to handle multiple assignment nodes
      class MultipleAssignment < self

        handle(:masgn)

        children :left, :right

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_singletons
        end

      end # MultipleAssignment
    end # Node
  end # Mutator
end # Mutant
