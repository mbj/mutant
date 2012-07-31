module Mutant
  class Mutator
    # Mutator for range literal AST nodes
    class Range < AbstractRange

    private

      # Return inverse 
      #
      # @return [Rubinius::AST::RangeExclude]
      #
      # @api private
      #
      def inverse(*arguments)
        new(Rubinius::AST::RangeExclude,*arguments)
      end
    end
  end
end
