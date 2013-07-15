module Mutant
  class Mutator
    class Node
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
          emit_nil
          emit_expression_mutations
          emit(expression)
        end

      end # Splat
    end # Node
  end # Mutator
end # Mutant
