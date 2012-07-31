module Mutant
  class Mutator
    # Abstract literal range mutator
    class AbstractRange < Mutator

    private

      # Emit mutants
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_nil
        emit_safe(inverse(node.start, node.finish))
        emit_range
      end

      # Emit range specific mutants
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_range
        start, finish = node.start, node.finish
        emit_self(negative_infinity, finish)
        emit_self(nan, finish)
        emit_self(start, infinity)
        emit_self(start, nan)
      end

      # Return inverse AST node class
      #
      # @return [Class:Rubinius::AST::Node]
      #
      # @api private
      #
      abstract :inverse_class
    end
  end
end

