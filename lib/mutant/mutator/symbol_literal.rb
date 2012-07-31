module Mutant
  class Mutator
    # Represent mutations on symbol literal
    class SymbolLiteral < Mutator

    private

      # Emit mutatns
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_nil
        emit_new { new_self(Mutant.random_hex_string.to_sym) }
      end
    end
  end
end
