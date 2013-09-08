# encoding: utf-8

module Mutant
  class Mutator
    class Node

      # OrAsgn mutator
      class OrAsgn < Generic

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
          super
          emit_nil
        end

      end # OrAsgn
    end # Node
  end # Mutator
end # Mutant
