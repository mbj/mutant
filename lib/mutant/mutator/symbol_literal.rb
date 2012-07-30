module Mutant
  class Mutator
    # Represent mutations on symbol literal
    class SymbolLiteral < Mutator
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
          new_self(Mutant.random_hex_string.to_sym)
        end
      end
    end
  end
end
