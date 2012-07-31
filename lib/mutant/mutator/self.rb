module Mutant
  class Mutator
    # Mutator for Rubinius::AST::Self 
    class Self < Mutator

      handle(Rubinius::AST::Self)
    
    private

      # Emit mutations
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        # noop
      end
    end
  end
end
