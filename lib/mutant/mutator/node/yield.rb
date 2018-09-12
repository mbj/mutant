# frozen_string_literal: true

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
        def dispatch
          super()
          emit_singletons
          children.each_index(&method(:delete_child))
        end

      end # Yield
    end # Node
  end # Mutator
end # Mutant
