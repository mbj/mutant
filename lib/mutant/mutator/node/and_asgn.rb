# encoding: utf-8

module Mutant
  class Mutator
    class Node

      # AndAsgn mutator
      class AndAsgn < Generic

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
          super
          emit_nil
        end

      end # AndAsgn
    end # Node
  end # Mutator
end # Mutant
