# encoding: utf-8

module Mutant
  class Mutator
    class Node

      # Mutator for super with parentheses
      class Super < self

        handle(:super)

        Z_SUPER = NodeHelpers.s(:zsuper)
        EMPTY_SUPER = NodeHelpers.s(:super)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit(Z_SUPER)
          emit(EMPTY_SUPER)
          children.each_index do |index|
            mutate_child(index)
            delete_child(index)
          end
        end

      end # Super
    end # Node
  end # Mutator
end # Mutant
