module Mutant
  class Mutator
    # Mutator for Rubinius::AST::Send
    class Call < Mutator
      class SendWithArguments < Call

        handle(Rubinius::AST::SendWithArguments)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        # FIXME: There are MANY more mutations here :P
        #
        def dispatch
          emit_explicit_receiver
        end
      end
    end
  end
end
