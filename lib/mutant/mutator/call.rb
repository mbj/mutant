module Mutant
  class Mutator
    # Abstract class for mutatiosn where messages are send
    class Call < Mutator

      private


      # Return receiver AST node
      #
      # @return [Rubinius::AST::Node]
      #
      # @api private
      #
      def receiver
        node.receiver
      end

      # Return name of call
      #
      # @return [Symbol]
      #
      # @api private
      #
      def name
        node.name
      end

      # Check if receiver is self
      #
      # @return [true]
      #   returns true when receiver is a Rubinius::AST::Self node
      #
      # @return [false]
      #   return false otherwise
      #
      # @api private
      #
      def self?
        receiver.kind_of?(Rubinius::AST::Self)
      end

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
          emit_explicit_self_receiver
        end

        # Emit an explicit self receiver if receiver is self
        #
        # Transforms a call on self with implict receiver into one with 
        # explcit receiver.
        #
        #   foo => self.foo
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_explicit_self_receiver
          emit_self(receiver,name,false,false)
        end
      end

      class SendWithArguments < Call
        
        handle(Rubinius::AST::SendWithArguments)

        private

        # Emut mutations
        #
        # @return [undefined]
        #
        # @api private
        #
        def dispatch
          emit_explicit_self_receiver
        end

        # Emit an explicit self receiver if receiver is self
        #
        # Transforms a call on self with implict receiver into one with 
        # explcit receiver.
        #
        #   foo => self.foo
        #
        # @return [undefined]
        #
        # @api private
        #
        def emit_explicit_self_receiver
          emit_self(receiver,name,false,false)
        end
      end
    end
  end
end
