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
          emit(send)
          emit_arguments_mutations
          if body
            emit_body_mutations
          else
            emit_body(NEW_OBJECT)
          end
        end

      end # Block
    end # Node
  end # Mutator
end # Mutant
