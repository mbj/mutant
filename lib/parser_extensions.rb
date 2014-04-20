# Monkey patch to parser that needs to be pushed upstream
module Parser
  # AST namespace
  module AST
    # The AST nodes we use in mutant
    class Node

      # Return hash compatible with #eql?
      #
      # @return [Fixnum]
      #
      # @api private
      def hash
        @type.hash ^ @children.hash ^ self.class.hash
      end

      # Test if node is equal to anotheo
      #
      # @return [true]
      #   if node represents the same code semantics locations are ignored
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def eql?(other)
        other.kind_of?(self.class)
        other.type.eql?(@type) && other.children.eql?(@children)
      end

    end # Node
  end # AST
end # Parser


