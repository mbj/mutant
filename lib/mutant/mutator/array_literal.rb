module Mutant
  class Mutator
    # Mutator for array literals
    class ArrayLiteral < Mutator

    private

      # Emit mutations
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        body = node.body
        emit_nil
        emit_self([])
        emit_self(body.dup << new_nil)
        emit_element_presence(body)
        emit_elements(body)
      end
    end
  end
end
