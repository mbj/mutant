module Mutant
  class Mutator
    # Mutator for empty array literals
    class EmptyArray < Mutator

    private

      # Append mutations on empty literals
      #
      # @param [#<<] generator
      #
      # @return [undefined]
      #
      # @api private
      #
      def mutants(generator)
        generator << new_nil
        generator << new(Rubinius::AST::ArrayLiteral,[new_nil])
      end
    end
  end
end
