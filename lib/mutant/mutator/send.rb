module Mutant
  class Mutator
    # Mutator for Rubinius::AST::Send
    class Send < Mutator

      handle(Rubinius::AST::Send)

    private

      # Emit mutations
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        # Mutate "self.foo" into "foo"
        emit_self(node.receiver,node.name,true,true)
      end
    end
  end
end
