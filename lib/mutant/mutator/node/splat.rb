# encoding: utf-8

module Mutant
  class Mutator
    class Node
      # Mutator for splat nodes
      class Splat < self

        handle :splat

        children :expression

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_singletons
          emit_expression_mutations
          emit(expression)
        end

      end # Splat
    end # Node
  end # Mutator
end # Mutant
