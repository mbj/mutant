# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # OrAsgn mutator
      class OrAsgn < self

        handle(:or_asgn)

        children :left, :right

      private

        def dispatch
          emit_singletons
          emit_right_mutations
          emit(s(:and_asgn, *children))
        end

      end # OrAsgn
    end # Node
  end # Mutator
end # Mutant
