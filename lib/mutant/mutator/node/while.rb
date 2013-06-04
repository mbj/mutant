module Mutant
  class Mutator
    class Node

      # Mutator for while expressions
      class While < self

        handle(:while)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_attribute_mutations(:condition)
          emit_attribute_mutations(:body)
        end

      end # While
    end # Node
  end # Mutator
end # Mutant
