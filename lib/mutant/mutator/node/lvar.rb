module Mutant
  class Mutator
    class Node

      # Mutation emitter to handle local variable nodes
      class LocalVariable < self

        handle(:lvar)

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

      end # LocalVariable
    end # Node
  end # Mutator
end # Mutant
