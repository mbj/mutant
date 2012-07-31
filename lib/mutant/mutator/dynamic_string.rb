module Mutant
  class Mutator
    # Represent mutations on dynamic literal
    class DynamicString < Mutator

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
