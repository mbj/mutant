# frozen_string_literal: true

module Mutant
  class AST
    module Regexp
      class Transformer
        # Transformer for option groups
        class OptionsGroup < self
          register :regexp_options_group
          register :regexp_options_switch_group

          # Mapper from `Regexp::Expression` to `Parser::AST::Node`
          class ExpressionToAST < Transformer::ExpressionToAST

            # Transform options group into node
            #
            # @return [Parser::AST::Node]
            def call
              quantify(ast(expression.option_changes, *children))
            end
          end # ExpressionToAST

          # Mapper from `Parser::AST::Node` to `Regexp::Expression`
          class ASTToExpression < Transformer::ASTToExpression
            include NamedChildren

            children :option_changes

          private

            def transform
              options_group.tap do |expression|
                expression.expressions = subexpressions
              end
            end

            def subexpressions
              remaining_children.map(&Regexp.public_method(:to_expression))
            end

            def options_group
              ::Regexp::Expression::Group::Options.new(
                ::Regexp::Token.new(:group, type, text)
              )
            end

            def type
              {
                regexp_options_group:        :options,
                regexp_options_switch_group: :options_switch
              }.fetch(node.type)
            end

            def text
              pos, neg = option_changes.partition { |_opt, val| val }.map do |arr|
                arr.map(&:first).join
              end
              neg_opt_sep = '-' unless neg.empty?
              content_sep = ':' unless type.equal?(:options_switch)

              "(?#{pos}#{neg_opt_sep}#{neg}#{content_sep}"
            end
          end # ASTToExpression
        end # OptionsGroup
      end # Transformer
    end # Regexp
  end # AST
end # Mutant
