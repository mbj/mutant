# frozen_string_literal: true

module Mutant
  class AST
    # Regexp source mapper
    module Regexp
      # Parse regex string into expression
      #
      # @param regexp [String]
      #
      # @return [Regexp::Expression, nil]
      def self.parse(regexp)
        ::Regexp::Parser.parse(regexp)
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

      # Convert's a `parser` `regexp` node into more fine-grained AST nodes.
      #
      # @param node [Parser::AST::Node]
      #
      # @return [Parser::AST::Node]
      def self.expand_regexp_ast(node)
        *body, _opts = node.children

        # NOTE: We only mutate parts of regexp body if the body is composed of
        # only strings. Regular expressions with interpolation are skipped
        return unless body.all? { |child| child.type.equal?(:str) }

        body_expression = parse(body.map(&:children).join)

        to_ast(body_expression)
      end
    end # Regexp
  end # AST
end # Mutant
