module Mutant
  class Mutator
    # Represent mutations on string literal
    class StringLiteral < Mutator

    private

      # Emit mutants
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_nil
        emit_new { new_self(Mutant.random_hex_string) }
      end
    end
  end
end
