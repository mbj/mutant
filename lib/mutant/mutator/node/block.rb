module Mutant
  class Mutator
    class Node
      # Mutator on AST blocks
      class Block < self

        handle(Rubinius::AST::Block)

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          array = input.array
          emit_body(array)
          if array.length > 1
            emit_element_presence(array)
          else
            emit_self([new_nil])
          end
        end
      end
    end
  end
end
