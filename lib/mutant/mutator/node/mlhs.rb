# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Mutator for multiple assignment left hand side nodes
      class MLHS < self

        handle(:mlhs)

      private

        def dispatch; end

      end # MLHS
    end # Node
  end # Mutator
end # Mutant
