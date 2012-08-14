module Mutant
  class Mutator
    class Define < self

      handle(Rubinius::AST::Define)

    private

      # Emit mutations
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_body_mutations
      end
    end
  end
end
