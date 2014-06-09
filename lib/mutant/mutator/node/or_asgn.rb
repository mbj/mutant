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
          unless left.type.equal?(:ivasgn)
            emit_left_mutations do |mutation|
              !mutation.type.equal?(:self)
            end
          end
          emit_right_mutations
        end

      end # OrAsgn
    end # Node
  end # Mutator
end # Mutant
