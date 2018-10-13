# frozen_string_literal: true

module Mutant
  module AST
    module Regexp
      class Transformer
        # Transformer for named groups
        class NamedGroup < self
          register :regexp_named_group

          # Mapper from `Regexp::Expression` to `Parser::AST::Node`
          class ExpressionToAST < Transformer::ExpressionToAST

            # Transform named group into node
            #
            # @return [Parser::AST::Node]
            def call
              quantify(ast(expression.name, *children))
            end
          end # ExpressionToAST

          # Mapper from `Parser::AST::Node` to `Regexp::Expression`
          class ASTToExpression < Transformer::ASTToExpression
            include NamedChildren

            children :name

          private

            # Convert node into expression
            #
            # @return [Regexp::Expression::Group::Named]
            def transform
              named_group.tap do |expression|
                expression.expressions = subexpressions
              end
            end

            # Recursive mapping of children
            #
            # @return [Array<Regexp::Expression>]
            def subexpressions
              remaining_children.map(&Regexp.public_method(:to_expression))
            end

            # Named group instance constructed using name
            #
            # @return [Regexp::Expression::Group::Named]
            def named_group
              ::Regexp::Expression::Group::Named.new(
                ::Regexp::Token.new(:group, :named, "(?<#{name}>")
              )
            end
          end # ASTToExpression
        end # NamedGroup
      end # Transformer
    end # Regexp
  end # AST
end # Mutant
