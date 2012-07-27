module Mutant
  class Mutator
    # Represent mutations of true literal
    class TrueLiteral < Mutator
    
    private

      # Append mutants
      #
      # @param [#<<] generator
      #
      # @return [undefined]
      #
      def mutants(generator)
        generator << new(Rubinius::AST::NilLiteral)
        generator << new(Rubinius::AST::FalseLiteral)
      end
    end
  end
end
