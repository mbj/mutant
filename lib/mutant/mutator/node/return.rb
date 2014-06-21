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
          emit_singletons
          return unless value
          emit(value)
          emit_value_mutations
        end

      end # Return
    end # Node
  end # Mutator
end # Mutant
