# frozen_string_literal: true

module Mutant
  module AST
    module Regexp
      class Transformer
        # Transformer for regexp quantifiers
        class Quantifier < self
          # Mapper from `Regexp::Expression` to `Parser::AST::Node`
          class ExpressionToAST < Transformer::ExpressionToAST
            # Transform quantifier into node
            #
            # @return [Parser::AST::Node]
            def call
              ast(expression.min, expression.max)
            end

          private

            def type
              :"regexp_#{expression.mode}_#{expression.token}"
            end
          end # ExpressionToAST

          # Mapper from `Parser::AST::Node` to `Regexp::Expression`
          class ASTToExpression < Transformer::ASTToExpression
            include NamedChildren

            children :min, :max, :subject

            Quantifier = Class.new.include(Concord::Public.new(:type, :suffix, :mode))

            QUANTIFIER_MAP = IceNine.deep_freeze({
              regexp_greedy_zero_or_more:     [:zero_or_more, '*',  :greedy],
              regexp_greedy_one_or_more:      [:one_or_more,  '+',  :greedy],
              regexp_greedy_zero_or_one:      [:zero_or_one,  '?',  :greedy],
              regexp_possessive_zero_or_one:  [:zero_or_one,  '?+', :possessive],
              regexp_reluctant_zero_or_more:  [:zero_or_more, '*?', :reluctant],
              regexp_reluctant_one_or_more:   [:one_or_more,  '+?', :reluctant],
              regexp_possessive_zero_or_more: [:zero_or_more, '*+', :possessive],
              regexp_possessive_one_or_more:  [:one_or_more,  '++', :possessive],
              regexp_greedy_interval:         [:interval,     '',   :greedy],
              regexp_reluctant_interval:      [:interval,     '?',  :reluctant],
              regexp_possessive_interval:     [:interval,     '+',  :possessive]
            }.transform_values { |arguments| Quantifier.new(*arguments) }.to_h)

          private

            def transform
              Regexp.to_expression(subject).dup.tap do |expression|
                expression.quantify(type, text, min, max, mode)
              end
            end

            def text
              if type.equal?(:interval)
                interval_text + suffix
              else
                suffix
              end
            end

            def type
              quantifier.type
            end

            def suffix
              quantifier.suffix
            end

            def mode
              quantifier.mode
            end

            def quantifier
              QUANTIFIER_MAP.fetch(node.type)
            end

            def interval_text
              interval = [min, max].map { |num| num if num.positive? }.uniq
              "{#{interval.join(',')}}"
            end
          end # ASTToExpression

          ASTToExpression::QUANTIFIER_MAP.keys.each(&method(:register))
        end # Quantifier
      end # Transformer
    end # Regexp
  end # AST
end # Mutant
