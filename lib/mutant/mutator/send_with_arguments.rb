module Mutant
  class Mutator
    # Mutator for Rubinius::AST::Send
    class SendWithArguments < Mutator

      handle(Rubinius::AST::SendWithArguments)

    private

      # Emit mutations
      #
      # @return [undefined]
      #
      # @api private
      #
      # FIXME: #   There are MANY more mutations here :P
      #
      def dispatch
        # Mutate "foo(1)" into "self.foo(1)"
        emit_self(node.receiver,node.name,arguments,true)
      end

      def arguments
        new(Rubinius::AST::ArrayLiteral,node.arguments.array)
      end
    end
  end
end
