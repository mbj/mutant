module Mutant
  class Mutator
    # Mutator for regexp literal AST nodes
    class RegexLiteral < Mutator

    private

      # Emit mutants
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_nil
        emit_new { new_self(Mutant.random_hex_string,node.options) }
      end
    end
  end
end
