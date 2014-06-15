# encoding: UTF-8

module Mutant
  class Mutator
    class Node
      class Send
        # Base mutator for index operations
        class Index < self

          # Mutator for index assignments
          class Assign < self

            # Perform dispatch
            #
            # @return [undefined]
            #
            # @api private
            #
            def dispatch
              emit(receiver)
            end

          end # Assign
        end # Index
      end # Send
    end # Node
  end # Mutator
end # Mutant
