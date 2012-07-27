module Mutant
  class Mutator
    # Represent mutations on fixnum literal
    class FixnumLiteral < Mutator
    private
      # Append mutants
      #
      # @param [#<<] generator
      #
      # @return [undefined]
      #
      def mutants(generator)
        generator << new(Rubinius::AST::NilLiteral)
        generator << new_self(0)
        generator << new_self(1)
        generator << new_self(-node.value)
        generator << new_self(Mutant.random_fixnum)
      end
    end
  end
end
