# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Kwbegin mutator
      class Kwbegin < Generic

        handle(:kwbegin)

      private

        def dispatch
          super()
          emit_singletons
        end

      end # Kwbegin
    end # Node
  end # Mutator
end # Mutant
