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
          emit_left_mutations do |mutation|
            !mutation.type.equal?(:self)
          end
          emit_right_mutations
        end

      end # AndAsgn
    end # Node
  end # Mutator
end # Mutant
