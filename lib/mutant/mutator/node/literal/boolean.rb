# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Literal < self
        # Abstract mutator for boolean literals
        class Boolean < self

        private

          MAP = {
            true:  :false,
            false: :true
          }.freeze

          handle(*MAP.keys)

          # Emit mutations
          #
          # @return [undefined]
          def dispatch
            emit_nil
            emit(s(MAP.fetch(node.type)))
          end

        end # Boolean
      end # Literal
    end # Node
  end # Mutator
end # Mutant
