module Mutant
  class Mutator
    # Mutator on AST blocks
    class Block < self

      handle(Rubinius::AST::Block)

    private

      # Emit mutants
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        array = node.array
        emit_elements(array)
        if array.length > 1
          emit_element_presence(array)
        else
          emit_self([new_nil])
        end
      end
    end
  end
end
