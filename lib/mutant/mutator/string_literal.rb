module Mutant
  class Mutator
    # Represent mutations on string literal
    class StringLiteral < Mutator

    private

      # Append mutants
      #
      # @param [#<<] generator
      #
      # @return [undefined]
      #
      def mutants(generator)
        generator << new_nil
        generator.generate do
          new_self(Mutant.random_hex_string)
        end
      end
    end
  end
end
