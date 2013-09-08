# encoding: utf-8

module Mutant
  class Mutator
    class Node

      # Dstr mutator
      class Dstr < Generic

        handle(:dstr)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          super
          emit_nil
        end

      end # Dstr
    end # Node
  end # Mutator
end # Mutant
