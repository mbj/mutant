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
            Util::Symbol.call(value).each(&method(:emit_type))
          end

        end # Symbol
      end # Literal
    end # Node
  end # Mutator
end # Mutant
