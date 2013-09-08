# encoding: utf-8

module Mutant
  class Mutator
    class Node

      # OpAsgn mutator
      class OpAsgn < Generic

        handle(:op_asgn)

        children :left, :right

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          super
          emit_nil
        end

      end # OpAsgn
    end # Node
  end # Mutator
end # Mutant
