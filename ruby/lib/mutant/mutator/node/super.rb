# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutator for super with parentheses
      class Super < self

        handle(:super)

      private

        def dispatch
          emit_singletons
          children.each_index do |index|
            mutate_child(index)
            delete_child(index)
          end
        end

      end # Super
    end # Node
  end # Mutator
end # Mutant
