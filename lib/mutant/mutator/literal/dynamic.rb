module Mutant
  class Mutator
    class Literal
      # Abstract mutations on dynamic literals
      class Dynamic < self

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_nil
        end
      end
    end
  end
end
