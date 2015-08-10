module Mutant
  class Mutator
    class Node
      # Namespace for define mutations
      class Defined < self

        handle(:defined?)

        children :expression

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        def dispatch
          emit_expression_mutations do |node|
            !n_self?(node)
          end

          emit_bools
        end

        # Emit booleans
        #
        # @return [undefined]
        #
        # @api private
        def emit_bools
          emit(N_TRUE)
          emit(N_FALSE)
        end

      end # Defined
    end # Node
  end # Mutator
end # Mutant
