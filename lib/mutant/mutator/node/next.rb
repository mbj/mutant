# encoding: utf-8

module Mutant
  class Mutator
    class Node

      # Next mutator
      class Next < Generic

        handle(:next)

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
          emit(s(:break, *children))
          emit_nil
        end

      end # Next
    end # Node
  end # Mutator
end # Mutant
