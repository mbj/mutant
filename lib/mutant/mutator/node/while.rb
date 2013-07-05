module Mutant
  class Mutator
    class Node

      # Mutator for while expressions
      class While < self

        handle(:while)

        children :condition, :body

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_condition_mutations
          emit_body_mutations
          emit_body(nil)
        end

      end # While
    end # Node
  end # Mutator
end # Mutant
