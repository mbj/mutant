module Mutant
  class Mutator
    class Node
      # Mutator for return statements
      class Return < self

        handle(:return)

        VALUE_INDEX = 0

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          value = children.first
          if value
            emit(value)
            mutate_child(VALUE_INDEX)
          else
            emit_nil
          end
        end

      end # Return
    end # Node
  end # Mutator
end # Mutant
