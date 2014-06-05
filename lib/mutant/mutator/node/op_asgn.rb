# encoding: utf-8

module Mutant
  class Mutator
    class Node

      # OpAsgn mutator
      class OpAsgn < self

        handle(:op_asgn)

        children :left, :operation, :right

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

      end # OpAsgn
    end # Node
  end # Mutator
end # Mutant
