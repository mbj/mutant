# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Mutator for ensure nodes
      class Ensure < self

        handle(:ensure)

        children :body, :ensure_body

      private

        def dispatch
          emit(body) if body
          emit_body_mutations if body
          emit_ensure_body_mutations if ensure_body
        end

      end # Ensure
    end # Node
  end # Mutator
end # Mutant
