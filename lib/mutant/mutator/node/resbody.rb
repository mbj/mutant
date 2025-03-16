# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Mutator for resbody nodes
      class Resbody < self

        handle(:resbody)

        children :captures, :assignment, :body

      private

        def dispatch
          emit_body_mutations if body
        end
      end # Resbody
    end # Node
  end # Mutator
end # Mutant
