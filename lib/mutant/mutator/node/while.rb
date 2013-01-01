module Mutant
  class Mutator
    class Node
      class While < self

        handle(Rubinius::AST::While)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_attribute_mutations(:condition)
          emit_attribute_mutations(:body)
        end

      end
    end
  end
end
