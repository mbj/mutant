# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Dstr mutator
      class Dstr < Generic

        handle(:dstr)

      private

        def dispatch
          super()
          emit_singletons
        end

      end # Dstr
    end # Node
  end # Mutator
end # Mutant
