# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # AndAsgn mutator
      class AndAsgn < self

        handle(:and_asgn)

        children :left, :right

      private

        def dispatch
          emit_left_mutations
          emit_right_mutations
        end

      end # AndAsgn
    end # Node
  end # Mutator
end # Mutant
