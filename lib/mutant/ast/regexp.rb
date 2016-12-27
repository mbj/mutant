module Mutant
  module AST
    # Regexp source mapper
    module Regexp
      UNSUPPORTED_EXPRESSION_TYPE = :conditional

      private_constant(*constants(false))

      # Parse regex string into expression
      #
      # @param regexp [String]
      #
      # @return [Regexp::Expression]
      def self.parse(regexp)
        ::Regexp::Parser.parse(regexp)
      end

      # Check if expression is supported by mapper
      #
      # @param expression [Regexp::Expression]
      #
      # @return [Boolean]
      def self.supported?(expression)
        expression.terminal? || expression.all? do |subexp|
          !subexp.type.equal?(UNSUPPORTED_EXPRESSION_TYPE) && supported?(subexp)
        end
      end

      # Convert expression into ast node
      #
      # @param expression [Regexp::Expression]
      #
      # @return [Parser::AST::Node]
      def self.to_ast(expression)
        ast_type = :"regexp_#{expression.token}_#{expression.type}"

        Transformer.lookup(ast_type).to_ast(expression)
      end

      # Convert node into expression
      #
      # @param node [Parser::AST::Node]
      #
      # @return [Regexp::Expression]
      def self.to_expression(node)
        Transformer.lookup(node.type).to_expression(node)
      end
    end # Regexp
  end # AST
end # Mutant
