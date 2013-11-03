# encoding: utf-8

module Mutant
  class Mutator
    class Node

      # Yield mutator
      class Yield < Generic

        handle(:yield)

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
          emit_nil
        end

      end # Yield
    end # Node
  end # Mutator
end # Mutant
