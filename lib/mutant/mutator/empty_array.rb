module Mutant
  class Mutator
    class EmptyArray < Mutator

    private

      def mutants(generator)
        generator << new_nil
        generator << new(Rubinius::AST::ArrayLiteral,[new_nil])
      end
    end
  end
end
