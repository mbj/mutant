module Mutant
  class Mutator
    # Represent mutations of false literal
    class FalseLiteral < Boolean
  
    private

      # Return inverse class
      #
      # @return [Rubinius::AST::TrueLiteral]
      #
      # @api private
      #
      def inverse
        new(Rubinius::AST::TrueLiteral)
      end
    end
  end
end
