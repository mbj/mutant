# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Namespace for singleton class mutations (class << some_obj)
      class Sclass < self
        handle :sclass

        children :expr, :body

      private

        # Emit mutations only for class body
        #
        # @return [undefined]
        def dispatch
          emit_body_mutations if body
        end
      end # Class
    end # Node
  end # Mutator
end # Mutant
