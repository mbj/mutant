module Mutant
  module AST
    module Regexp
      class Transformer
        # Transformer for Regexp `alternative` nodes
        #
        # This transformer is very similar to the generic recursive mapper
        # except for the fact that the `Regexp::Expression` class for
        # `alternative` nodes has a unique constructor
        class Alternative < self
          register :regexp_sequence_expression

          # Mapper from `Regexp::Expression` to `Parser::AST::Node`
          ExpressionToAST = Class.new(Recursive::ExpressionToAST)

          # Mapper from `Parser::AST::Node` to `Regexp::Expression`
          class ASTToExpression < Transformer::ASTToExpression
            # Alternative instance with dummy values for `level`, `set_level`,
            # and `conditional_level`. These values do not affect unparsing
            ALTERNATIVE = IceNine.deep_freeze(
              ::Regexp::Expression::Alternative.new(0, 0, 0)
            )

          private

            # Transform ast into expression
            #
            # @return [Regexp::Expression::Alternative]
            def transform
              ALTERNATIVE.dup.tap do |alt|
                alt.expressions = subexpressions
              end
            end
          end # ASTToExpression
        end # Alternative
      end # Transformer
    end # Regexp
  end # AST
end # Mutant
