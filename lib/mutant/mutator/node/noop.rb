module Mutant
  class Mutator
    class Node
      # Mutator that does not do mutations on ast
      class Noop < self

        # Literal references to self do not need to be mutated?
        handle(
          :self, :zsuper, :not, :or, :and, :defined,
          :next, :break, :match, :gvar, :cvar, :ensure, :rescue, 
          :dstr, :dsym, :yield, :begin, :rescue
        )

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
end
