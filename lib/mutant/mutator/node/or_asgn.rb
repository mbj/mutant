module Mutant
  class Mutator
    class Node

      # OpAsgn mutator
      class OrAsgn < self

        handle(:or_asgn)

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
          emit_right_mutations
          return if n_ivasgn?(left)
          emit_left_mutations do |node|
            AST::Meta.for(node).assignment?
          end
        end

      end # OrAsgn
    end # Node
  end # Mutator
end # Mutant
