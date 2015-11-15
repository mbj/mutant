module Mutant
  class Mutator
    class Node
      class Literal < self
        # Mutator for symbol literals
        class Symbol < self

          handle(:sym)

          children :value

          PREFIX = '__mutant__'.freeze

        private

          # Emit mutants
          #
          # @return [undefined]
          def dispatch
            emit_singletons
            Mutator::Util::Symbol.each(value, self) do |value|
              emit_type(value)
            end
          end

        end # Symbol
      end # Literal
    end # Node
  end # Mutator
end # Mutant
