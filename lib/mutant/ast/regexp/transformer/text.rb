module Mutant
  module AST
    module Regexp
      class Transformer
        # Regexp AST transformer for nodes that encode a text value
        class Text < self
          # Mapper from `Regexp::Expression` to `Parser::AST::Node`
          class ExpressionToAST < Transformer::ExpressionToAST
            # Transform expression into node preserving text value
            #
            # @return [Parser::AST::Node]
            def call
              quantify(ast(expression.text))
            end
          end # ExpressionToAST

          # Mapper from `Parser::AST::Node` to `Regexp::Expression`
          class ASTToExpression < Transformer::ASTToExpression
            include LookupTable

            TABLE = Table.create(
              [:regexp_literal_literal,       %i[literal literal],       ::Regexp::Expression::Literal],
              [:regexp_comment_group,         %i[group comment],         ::Regexp::Expression::Group::Comment],
              [:regexp_named_group,           %i[group named],           ::Regexp::Expression::Group::Named],
              [:regexp_number_backref,        %i[backref number],        ::Regexp::Expression::Backreference::Number],
              [:regexp_name_call_backref,     %i[backref name_call],     ::Regexp::Expression::Backreference::NameCall],
              [:regexp_whitespace_free_space, %i[free_space whitespace], ::Regexp::Expression::WhiteSpace],
              [:regexp_comment_free_space,    %i[free_space comment],    ::Regexp::Expression::WhiteSpace],
              [:regexp_hex_escape,            %i[escape hex],            ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_literal_escape,        %i[escape literal],        ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_backslash_escape,      %i[escape backslash],      ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_tab_escape,            %i[escape tab],            ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_codepoint_list_escape, %i[escape codepoint_list], ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_codepoint_escape,      %i[escape codepoint],      ::Regexp::Expression::EscapeSequence::Literal],
              [:regexp_control_escape,        %i[escape control],        ::Regexp::Expression::EscapeSequence::Control],
              [:regexp_meta_sequence_escape,  %i[escape meta_sequence],  ::Regexp::Expression::EscapeSequence::Control]
            )

          private

            # Transform node to expression with text value
            #
            # @return [Regexp::Expression]
            def transform
              token = expression_token.dup
              token.text = Util.one(node.children)
              expression_class.new(token)
            end
          end # ASTToExpression

          ASTToExpression::TABLE.types.each(&method(:register))
        end # Text
      end # Transformer
    end # Regexp
  end # AST
end # Mutant
