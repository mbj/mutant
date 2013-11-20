# encoding: utf-8

module Mutant
  class Mutator
    class Node

      # Mutator for loop control keywords
      class LoopControl < Generic

        INVERSE = IceNine.deep_freeze(
          next: :break,
          break: :next
        )

        handle(*INVERSE.keys)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          super
          children.each_index(&method(:delete_child))
          emit(s(INVERSE.fetch(node.type), *children))
          emit_nil
        end

      end # Next
    end # Node
  end # Mutator
end # Mutant
