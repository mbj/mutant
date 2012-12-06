module Mutant
  class Mutator
    class Node
      # Mutator for arguments
      class Arguments < self

        handle(Rubinius::AST::ActualArguments)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_argument_mutations
        end

        # Emit argument mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_argument_mutations
          Mutator::Util::Array.each(node.array) do |mutation|
            dup = dup_input
            dup.array = mutation
            emit(dup)
          end
        end

      end
    end
  end
end
