module Mutant
  class Mutator
    class Node
      # Mutantor for default arguments
      class DefaultArguments < self
        handle(Rubinius::AST::DefaultArguments)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_attribute_mutations(:arguments) do |argument|
            argument.names = argument.arguments.map(&:name)
            argument
          end
        end
      end
    end
  end
end
