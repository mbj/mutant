# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Literal
        # Mutator for string literals
        class String < self

          handle(:str)

        private

          def dispatch
            emit_singletons
            emit(N_EMPTY_STRING)
            SqlHeredoc.mutate(input).each(&method(:emit))
          end

        end # String
      end # Literal
    end # Node
  end # Mutator
end # Mutant
