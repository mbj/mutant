# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutator for super without parentheses
      class ZSuper < self

        handle(:zsuper)

      private

        def dispatch
          emit_singletons
        end

      end # ZSuper
    end # Node
  end # Mutator
end # Mutant
