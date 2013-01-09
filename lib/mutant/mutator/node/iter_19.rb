module Mutant
  class Mutator
    class Node
      # Emitter for mutations on 19 blocks
      class Iter19 < self

        handle(Rubinius::AST::Iter19)

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_attribute_mutations(:body)
          emit_attribute_mutations(:arguments) do |mutation|
            arguments = mutation.arguments
            arguments.names = arguments.required + arguments.optional
            mutation
          end if node.arguments
        end

      end
    end
  end
end
