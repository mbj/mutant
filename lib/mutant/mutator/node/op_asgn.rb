# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # OpAsgn mutator
      class OpAsgn < self

        handle(:op_asgn)

        children :left, :operation, :right

      private

        def dispatch
          left_mutations

          emit_right_mutations
        end

        def left_mutations
          emit_left_mutations do |node|
            !n_self?(node)
          end
          emit_left_promotion if n_send?(left)
        end

        def emit_left_promotion
          receiver = left.children.first

          emit_left(s(:ivasgn, *receiver)) if n_ivar?(receiver)
        end

      end # OpAsgn
    end # Node
  end # Mutator
end # Mutant
