module Mutant
  class Mutator
    class Node

      # OpAsgn mutator
      class AndAsgn < self

        handle(:and_asgn)

        children :left, :right

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_singletons
          emit_left_mutations do |node|
            !n_self?(node)
          end
          emit_right_mutations
        end

      end # AndAsgn
    end # Node
  end # Mutator
end # Mutant
