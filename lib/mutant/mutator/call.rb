module Mutant
  class Mutator
    # Abstract class for mutatiosn where messages are send
    class Call < Mutator

      handle(Rubinius::AST::Send)

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

      def emit_explicit_self_receiver
        mutant = dup_node
        mutant.privately = false
        # TODO: Fix rubinius to allow this as an attr_accessor
        mutant.instance_variable_set(:@vcall_style,false)
        emit_safe(mutant)
      end

      # Emit mutations
      #
      # @return [undefined]
      #
      # @api private
      #
      def dispatch
        emit_explicit_self_receiver
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
      end
    end
  end
end
