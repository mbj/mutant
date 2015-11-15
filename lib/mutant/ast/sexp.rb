module Mutant
  module AST
    # Mixin for node sexp syntax
    module Sexp

    private

      # Build node
      #
      # @param [Symbol] type
      #
      # @return [Parser::AST::Node]
      def s(type, *children)
        ::Parser::AST::Node.new(type, children)
      end

      # Build a negated boolean node
      #
      # @param [Parser::AST::Node] node
      #
      # @return [Parser::AST::Node]
      def n_not(node)
        s(:send, node, :!)
      end

    end # Sexp
  end # AST
end # Mutant
