# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutator for when nodes
      class When < self

        handle(:when)

      private

        def dispatch
          if body
            mutate_body
          else
            emit_child_update(body_index, N_RAISE)
          end
          mutate_conditions
        end

        def mutate_conditions
          conditions = children.length - 1
          children[..-2].each_index do |index|
            delete_child(index) if conditions > 1
            mutate_child(index)
          end
        end

        def mutate_body
          mutate_child(body_index)
        end

        def body
          children.fetch(body_index)
        end

        def body_index
          children.length - 1
        end

      end # When
    end # Node
  end # Mutator
end # Mutant
