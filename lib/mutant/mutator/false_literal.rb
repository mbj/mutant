module Mutant
  class Mutator
    # Represent mutations of false literal
    class FalseLiteral < Mutator
    
    private

      # Append mutants
      #
      # @param [#<<] generator
      #
      # @return [undefined]
      #
      def mutants(generator)
        generator << new_nil
        generator << new(Rubinius::AST::TrueLiteral)
      end
    end
  end
end
