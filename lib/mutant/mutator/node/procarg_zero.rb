# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class ProcargZero < self

        handle :procarg0

      private

        def dispatch
          children.each_index(&method(:mutate_child))
        end
      end # ProcargZero
    end # Node
  end # Mutator
end # Mutant
