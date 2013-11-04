# encoding: utf-8

module Mutant
  class Mutator
    class Node

      # Break mutator
      class Break < Generic

        handle(:break)

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
          emit(s(:next, *children))
          emit_nil
        end

      end # Break
    end # Node
  end # Mutator
end # Mutant
