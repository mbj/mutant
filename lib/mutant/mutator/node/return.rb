module Mutant
  class Mutator
    class Node
      # Mutator for return statements
      class Return < self

        handle(Rubinius::AST::Return)

      private


        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          value = node.value
          if value
            emit(value)
          else
            emit_nil
          end
        end

      end
    end
  end

end
