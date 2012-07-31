module Mutant
  class Mutator
    # Mutator for empty array literals
    class EmptyArray < Mutator

    private

      # Emit mutants
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_nil
        emit(Rubinius::AST::ArrayLiteral, [new_nil])
      end
    end
  end
end
