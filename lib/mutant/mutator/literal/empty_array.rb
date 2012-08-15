module Mutant
  class Mutator
    class Literal < self
      # Mutator for empty array literals
      class EmptyArray < self

        handle(Rubinius::AST::EmptyArray)

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_nil
          emit_node(Rubinius::AST::ArrayLiteral, [new_nil])
        end
      end
    end
  end
end
