module Mutant
  class Mutator
    # Abstract mutator for boolean literals
    class Boolean < Mutator

    private

      # Emit mutants
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_nil
        emit_safe(inverse)
      end

      # Return inverse
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      abstract :inverse
    end
  end
end
