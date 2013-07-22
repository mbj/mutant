module Mutant
  class Mutator
    class Node

      # Mutation emitter to handle variable nodes
      class Variable < self

        handle(:gvar, :cvar, :ivar, :lvar)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_nil
        end

      end # Variable
    end # Node
  end # Mutator
end # Mutant
