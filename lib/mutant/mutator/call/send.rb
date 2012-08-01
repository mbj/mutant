module Mutant
  class Mutator
    class Call < Mutator
      # Mutator for Rubinius::AST::Send
      class Send < Call

        handle(Rubinius::AST::Send)

      private

        # Emit mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_explicit_receiver
        end

        # Emit a private vcall mutation
        #
        # Transforms a call on self with implict receiver into one with 
        # explcit receiver.
        #
        #   foo(1) => self.foo(1)
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_explicit_receiver
          emit_self(receiver,name,false,true)
        end
      end
    end
  end
end
