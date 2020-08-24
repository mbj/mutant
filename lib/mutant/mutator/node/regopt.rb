# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Regular expression options mutation
      class Regopt < self

        MUTATED_FLAGS = IceNine.deep_freeze(%i[i])

        handle(:regopt)

      private

        def dispatch
          emit_type(*mutated_flags)
        end

        def mutated_flags
          (children - MUTATED_FLAGS)
        end

      end # Regopt
    end # Node
  end # Mutator
end # Mutant
