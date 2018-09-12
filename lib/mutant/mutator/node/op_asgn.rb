# frozen_string_literal: true

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
        def dispatch
          emit_singletons
          emit_left_mutations do |node|
            !n_self?(node)
          end
          emit_right_mutations
        end

      end # OpAsgn
    end # Node
  end # Mutator
end # Mutant
