module Mutant
  class Mutator
    class Node
      class Arguments < self

        handle(:args)

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_children_mutations
        end

      end # Arguments
    end # Node
  end # Mutator
end # Mutant
