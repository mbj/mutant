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
    end
  end
end
