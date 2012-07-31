module Mutant
  class Mutator
    # Mutator for range exclude literals
    class RangeExclude < AbstractRange

    private

      # Return inverse node
      #
      # @return [Rubnius::AST::Range]
      #
      # @api private
      #
      def inverse(*arguments)
        new(Rubinius::AST::Range,*arguments)
      end
    end
  end
end
