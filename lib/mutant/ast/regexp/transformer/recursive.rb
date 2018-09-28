# frozen_string_literal: true

module Mutant
  module AST
    module Regexp
      class Transformer
        # Transformer for nodes with children
        class Recursive < self
          # Mapper from `Regexp::Expression` to `Parser::AST::Node`
          class ExpressionToAST < Transformer::ExpressionToAST
            # Transform expression and children into nodes
            #
            # @return [Parser::AST::Node]
            def call
              quantify(ast(*children))
            end
          end # ExpressionToAST

          # Mapper from `Parser::AST::Node` to `Regexp::Expression`
          class ASTToExpression < Transformer::ASTToExpression
            include LookupTable

            # rubocop:disable LineLength
            # Expression::Sequence represents conditional branches, alternation branches, and intersection branches
            TABLE = Table.create(
              [:regexp_alternation_meta,      [:meta,        :alternation,  '|'],    ::Regexp::Expression::Alternation],
              [:regexp_atomic_group,          [:group,       :atomic,       '(?>'],  ::Regexp::Expression::Group::Atomic],
              [:regexp_capture_group,         [:group,       :capture,      '('],    ::Regexp::Expression::Group::Capture],
              [:regexp_character_set,         [:set,         :character,    '['],    ::Regexp::Expression::CharacterSet],
              [:regexp_intersection_set,      [:set,         :intersection, '&&'],   ::Regexp::Expression::CharacterSet::Intersection],
              [:regexp_lookahead_assertion,   [:assertion,   :lookahead,    '(?='],  ::Regexp::Expression::Assertion::Lookahead],
              [:regexp_lookbehind_assertion,  [:assertion,   :lookbehind,   '(?<='], ::Regexp::Expression::Assertion::Lookbehind],
              [:regexp_nlookahead_assertion,  [:assertion,   :nlookahead,   '(?!'],  ::Regexp::Expression::Assertion::NegativeLookahead],
              [:regexp_nlookbehind_assertion, [:assertion,   :nlookbehind,  '(?<!'], ::Regexp::Expression::Assertion::NegativeLookbehind],
              [:regexp_open_conditional,      [:conditional, :open,         '(?'],   ::Regexp::Expression::Conditional::Expression],
              [:regexp_passive_group,         [:group,       :passive,      '(?:'],  ::Regexp::Expression::Group::Passive],
              [:regexp_range_set,             [:set,         :range,        '-'],    ::Regexp::Expression::CharacterSet::Range],
              [:regexp_sequence_expression,   [:expression,  :sequence,     ''],     ::Regexp::Expression::Sequence]
            )

          private

            # Transform nodes and their children into expressions
            #
            # @return [Regexp::Expression]
            def transform
              expression_class.new(expression_token).tap do |expression|
                expression.expressions = subexpressions
              end
            end
          end # ASTToExpression

          ASTToExpression::TABLE.types.each(&method(:register))
        end # Recursive
      end # Transformer
    end # Regexp
  end # AST
end # Mutant
