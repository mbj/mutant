module Mutant
  module AST
    module Regexp
      class Transformer
        # Transformer for option groups
        class OptionsGroup < self
          register :regexp_options_group

          # Mapper from `Regexp::Expression` to `Parser::AST::Node`
          class ExpressionToAST < Transformer::ExpressionToAST

            # Transform options group into node
            #
            # @return [Parser::AST::Node]
            def call
              quantify(ast(expression.options, *children))
            end
          end # ExpressionToAST

          # Mapper from `Parser::AST::Node` to `Regexp::Expression`
          class ASTToExpression < Transformer::ASTToExpression
            include NamedChildren

            children :options

          private

            # Covnert node into expression
            #
            # @return [Regexp::Expression::Group::Options]
            def transform
              options_group.tap do |expression|
                expression.expressions = subexpressions
              end
            end

            # Recursive mapping of children
            #
            # @return [Array<Regexp::Expression>]
            def subexpressions
              remaining_children.map(&Regexp.public_method(:to_expression))
            end

            # Options group instance constructed from options text
            #
            # @return [Regexp::Expression::Group::Options]
            def options_group
              ::Regexp::Expression::Group::Options.new(
                ::Regexp::Token.new(:group, :options, text)
              )
            end

            # Flag text constructed from enabled options
            #
            # @return [String]
            def text
              flags = options.map { |key, value| key if value }.join

              "(?#{flags}-:"
            end
          end # ASTToExpression
        end # OptionsGroup
      end # Transformer
    end # Regexp
  end # AST
end # Mutant
