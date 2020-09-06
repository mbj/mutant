# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class BlockPass < self

        handle(:block_pass)

        children :argument

      private

        def dispatch
          emit_argument_mutations
        end
      end # Block
    end # Node
  end # Mutator
end # Mutant
