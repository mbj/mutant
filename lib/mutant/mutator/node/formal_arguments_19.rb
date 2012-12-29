module Mutant
  class Mutator
    class Node

      # Mutator for formal arguments in 1.9 mode
      class FormalArguments19 < self

      private

        handle(Rubinius::AST::FormalArguments19)

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          run(DefaultMutations)
          run(RequireDefaults)
          run(PatternArgumentExpansion)
          emit_required_mutations
        end


        # Emit required mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_required_mutations
          emit_attribute_mutations(:required) do |mutation|
            mutation.names = mutation.optional + mutation.required
          end
        end
      end
    end
  end
end
