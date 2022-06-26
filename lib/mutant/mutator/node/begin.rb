# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutator for begin nodes
      class Begin < self

        handle(:begin)

      private

        def dispatch
          ignore_single = children.any?(&method(:ignore?))
          mutate_single_child do |child|
            emit(child) unless ignore_single
          end
        end
      end # Begin
    end # Node
  end # Mutator
end # Mutant
