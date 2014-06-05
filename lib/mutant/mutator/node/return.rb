# encoding: utf-8

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
          if value
            emit(value)
            emit_value_mutations
          end
        end

      end # Return
    end # Node
  end # Mutator
end # Mutant
