module Mutant
  class Mutator
    class Literal < Mutator
      # Mutator for regexp literal AST nodes
      class Regex < Literal

        handle(Rubinius::AST::RegexLiteral)

      private

        # Emit mutants
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_nil
          emit_new { new_self(Random.hex_string, node.options) }
        end
      end
    end
  end
end
