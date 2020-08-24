# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Dsym mutator
      class Dsym < Generic

        handle(:dsym)

      private

        def dispatch
          super()
          emit_singletons
        end

      end # Dsym
    end # Node
  end # Mutator
end # Mutant
