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
        def dispatch
          emit_singletons
          emit(send)
          emit_send_mutations(&method(:n_send?))
          emit_arguments_mutations

          mutate_body
        end

        # Emit body mutations
        #
        # @return [undefined]
        #
        # @api private
        def mutate_body
          emit_body(nil)
          emit_body(N_RAISE)

          return unless body
          emit(body)
          emit_body_mutations
        end

      end # Block
    end # Node
  end # Mutator
end # Mutant
