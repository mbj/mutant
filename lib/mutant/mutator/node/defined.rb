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
        #
        def dispatch
          emit_expression_mutations do |node|
            !n_self?(node)
          end
        end

      end # Defined
    end # Node
  end # Mutator
end # Mutant
