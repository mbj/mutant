module Mutant
  class Mutator
    class Node

      # Mutation emitter to handle multipl assignment nodes
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
          # noop, for now
        end

      end # MultipleAssignment
    end # Node
  end # Mutator
end # Mutant
