# encoding: utf-8

module Mutant
  class Mutator
    class Node
      # Emitter for mutations on 19 blocks
      class Block < self

        handle(:block)

        children :send, :arguments, :body

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_singletons
          emit(send)
          emit_arguments_mutations
          if body
            emit_body_mutations
          end
          emit_body(nil)
          emit_body(RAISE)
        end

      end # Block
    end # Node
  end # Mutator
end # Mutant
