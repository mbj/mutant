module Mutant
  class Mutator
    class Node

      # Regular expression options mutation
      class Regopt < self

        MUTATED_FLAGS = IceNine.deep_freeze(%i[i])

        handle(:regopt)

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          emit_type(*mutated_flags)
        end

        # Altered flags array excluding case insensitive flag
        #
        # @return [Array<Symbol>]
        def mutated_flags
          (children - MUTATED_FLAGS)
        end

      end # Regopt
    end # Node
  end # Mutator
end # Mutant
