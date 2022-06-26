# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for symbol literals
        class Symbol < self

          handle(:sym)

          children :value

        private

          def dispatch
            emit_singletons
            Util::Symbol.call(input: value, parent: nil).each(&method(:emit_type))
          end

        end # Symbol
      end # Literal
    end # Node
  end # Mutator
end # Mutant
