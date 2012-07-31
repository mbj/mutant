module Mutant
  class Mutator
    # Represent mutations on fixnum literal
    class FixnumLiteral < Mutator

    private

      # Emit mutants
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_nil
        emit_values(values)
        emit_new { new_self(Mutant.random_fixnum) }
      end

      # Return values to mutate against
      #
      # @return [Array]
      #
      # @api private
      #
      def values
        [0,1,-node.value]
      end
    end
  end
end
