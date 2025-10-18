# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Module < self
        handle :module

        children :klass, :body

      private

        def dispatch
          emit_body_mutations if body
        end
      end # Module
    end # Node
  end # Mutator
end # Mutant
