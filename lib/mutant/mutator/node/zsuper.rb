# encoding: utf-8

module Mutant
  class Mutator
    class Node

      # Mutator for super without parentheses
      class ZSuper < self

        handle(:zsuper)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_nil
        end

      end # ZSuper
    end # Node
  end # Mutator
end # Mutant
