module Mutant
  class Mutator
    class Node
      # Mutator for return statements
      class Return < self

        handle(:return)

        children :value

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          if value
            emit(value)
            emit_value_mutations
          else
            emit_nil
          end
        end

      end # Return
    end # Node
  end # Mutator
end # Mutant
