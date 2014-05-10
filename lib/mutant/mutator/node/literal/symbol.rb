# encoding: utf-8

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

          # Emit mutatns
          #
          # @return [undefined]
          #
          # @api private
          #
          def dispatch
            emit_nil
            Mutator::Util::Symbol.each(value, self) do |value|
              emit_self(value)
            end
          end

        end # Symbol
      end # Literal
    end # Node
  end # Mutator
end # Mutant
