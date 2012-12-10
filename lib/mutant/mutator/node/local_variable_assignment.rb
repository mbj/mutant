module Mutant
  class Mutator
    class Node 
      class LocalVariableAssignment < self

        handle(Rubinius::AST::LocalVariableAssignment)

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_attribute_mutations(:name)
          emit_attribute_mutations(:value)
        end

      end
    end
  end
end

