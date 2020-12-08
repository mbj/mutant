# frozen_string_literal: true

module Mutant
  class Mutator
    class Node

      # Mutation emitter to handle noop nodes
      class Noop < self

        handle(:__ENCODING__, :cbase, :lambda)

      private

        def dispatch
          # noop
        end

      end # Noop
    end # Node
  end # Mutator
end # Mutant
