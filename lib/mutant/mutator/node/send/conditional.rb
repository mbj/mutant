module Mutant
  class Mutator
    class Node
      class Send
        class Conditional < self

          handle(:csend)

        private

          # Emit mutations
          #
          # @return [undefined]
          def dispatch
            super()
            emit(s(:send, *children))
          end

        end # Conditional
      end # Send
    end # Node
  end # Mutator
end # Mutant
