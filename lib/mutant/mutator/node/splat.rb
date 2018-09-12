# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Mutator for splat nodes
      class Splat < self

        handle :splat

        children :expression

      private

        # Emit mutations
        #
        # @return [undefined]
        def dispatch
          emit_singletons
          emit_expression_mutations
          emit(expression)
        end

      end # Splat
    end # Node
  end # Mutator
end # Mutant
