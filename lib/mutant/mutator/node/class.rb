# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Namespace for class mutations
      class Class < self
        handle :class

        children :klass, :parent, :body

      private

        # Emit mutations only for class body
        #
        # @return [undefined]
        def dispatch
          mutate_type
          emit_body_mutations if body
        end

        # Emit class -> type mutations
        #
        # @return [undefined]
        def mutate_type
          emit(s(:module, klass, body))
        end
      end # Class
    end # Node
  end # Mutator
end # Mutant
