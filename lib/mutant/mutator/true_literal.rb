module Mutant
  class Mutator
    # Represent mutations of true literal
    class TrueLiteral < Boolean
  
    private

      # Return inverse
      #
      # @return [Rubinius::AST::FalseLiteral]
      #
      # @api private
      #
      def inverse
        new(Rubinius::AST::FalseLiteral)
      end
    end
  end
end
