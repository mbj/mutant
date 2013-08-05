# encoding: utf-8

module Mutant
  class Mutator
    class Node
      # Mutator for nth-ref nodes
      class NthRef < self

        handle :nth_ref

        children :number

      private

        # Perform dispatch
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_number(number - 1)
          emit_number(number + 1)
        end

      end # NthRef
    end # Node
  end # Mutator
end # Mutant
