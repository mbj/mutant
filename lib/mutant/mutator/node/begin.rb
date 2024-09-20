# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutator for begin nodes
      class Begin < self

        handle(:begin)

      private

        def dispatch
        # ignore_single = children.any?(&method(:ignore?))
        # mutate_single_child do |child|
        #   # emit(child) unless ignore_single
        # end
          children.each_with_index do |child, index|
            mutate_child(index) unless ignore?(child)
            case children.length
            when 0, 1
            when 2
              other_index = index.zero? ? 1 : 0
              other_child = children.fetch(other_index)
              emit(child) if !ignore?(child) && !ignore?(other_child) && !lvar_assignment?(other_child)
            else
              delete_child(index) if !lvar_assignment?(child)
            end
          end
        end

        def lvar_assignment?(node)
          n_lvasgn?(node) || n_masgn?(node)
        end
      end # Begin
    end # Node
  end # Mutator
end # Mutant
