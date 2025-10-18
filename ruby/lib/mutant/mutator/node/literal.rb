# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      # Abstract mutator for literal AST nodes
      class Literal < self
        include AbstractType

      private

        def emit_values
          values.each(&method(:emit_type))
        end
      end # Literal
    end # Node
  end # Mutator
end # Mutant
