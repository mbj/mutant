module Mutant
  class Mutator
    # Mutator that does do not mutations on ast
    class Noop < self

      # Literal references to self do not need to be mutated. 
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
