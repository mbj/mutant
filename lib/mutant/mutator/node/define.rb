module Mutant
  class Mutator
    class Node
      class Define < self

        handle(:define)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_attribute_mutations(:body)
          emit_attribute_mutations(:arguments)
        end

      end # Define
    end # Node
  end # Mutator
end # Mutant
