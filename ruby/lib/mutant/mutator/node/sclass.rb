# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Namespace for singleton class mutations (class << some_obj)
      class Sclass < self
        handle :sclass

        children :expr, :body

      private

        def dispatch
          emit_body_mutations if body
        end
      end # Sclass
    end # Node
  end # Mutator
end # Mutant
