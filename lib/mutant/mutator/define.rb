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
        Mutator.each(node.body) do |mutation|
          node = dup_node
          node.body = mutation
          emit_safe(node)
        end
      end
    end
  end
end
