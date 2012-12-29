module Mutant
  class Mutator
    class Node
      # Mutator for pattern arguments
      class PatternArguments < self

        handle(Rubinius::AST::PatternArguments)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          Mutator.each(node.arguments.body) do |mutation|
            dup = dup_node
            dup.arguments.body = mutation
            emit(dup)
          end
        end

        # Test if mutation should be skipped
        #
        # @return [true]
        #   if mutation should be skipped
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def allow?(object)
          object.arguments.body.size >= 2
        end
      end
    end
  end
end
