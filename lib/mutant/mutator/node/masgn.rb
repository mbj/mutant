# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutation emitter to handle multiple assignment nodes
      class MultipleAssignment < self

        handle(:masgn)

        children :left, :right

      private

        def dispatch
          emit_singletons
          emit_right_mutations
        end

      end # MultipleAssignment
    end # Node
  end # Mutator
end # Mutant
