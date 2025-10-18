# frozen_string_literal: true

module Mutant
  class Mutator
    class Node
      class Send
        class Conditional < self

          handle(:csend)

        private

          def dispatch
            super
            emit(s(:send, *children))
          end

        end # Conditional
      end # Send
    end # Node
  end # Mutator
end # Mutant
