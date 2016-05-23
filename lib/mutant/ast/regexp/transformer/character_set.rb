module Mutant
  module AST
    module Regexp
      class Transformer
        # Transformer for character sets
        #
        # The `Regexp::Expression` representation of a character set
        # is unique due to its usage of the `#members` attribute which
        # is why it gets its own transformer
        class CharacterSet < self
          register :regexp_character_set

          # Mapper from `Regexp::Expression` to `Parser::AST::Node`
          class ExpressionToAST < Transformer::ExpressionToAST
            # Transform character set expression into node
            #
            # @return [Parser::AST::Node]
            def call
              quantify(ast(*expression.members))
            end
          end # ExpressionToAST

          # Mapper from `Parser::AST::Node` to `Regexp::Expression`
          class ASTToExpression < Transformer::ASTToExpression
            CHARACTER_SET = IceNine.deep_freeze(
              ::Regexp::Expression::CharacterSet.new(
                ::Regexp::Token.new(:set, :character, '[')
              )
            )

          private

            # Transform node into expression
            #
            # @return [Regexp::Expression]
            def transform
              CHARACTER_SET.dup.tap do |expression|
                expression.members = node.children
              end
            end
          end # ASTToExpression
        end # CharacterSet
      end # Transformer
    end # Regexp
  end # AST
end # Mutant
