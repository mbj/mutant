# frozen_string_literal: true

module Mutant
  class Expression
    class Parser
      include Concord.new(:types)

      class ParserError < RuntimeError
        include AbstractType
      end # ParserError

      # Error raised on invalid expressions
      class InvalidExpressionError < ParserError; end

      # Error raised on ambiguous expressions
      class AmbiguousExpressionError < ParserError; end

      # Parse input into expression or raise
      #
      # @param [String] syntax
      #
      # @return [Expression]
      #   if expression is valid
      #
      # @raise [ParserError]
      #   otherwise
      def call(input)
        try_parse(input) or fail InvalidExpressionError, "Expression: #{input.inspect} is not valid"
      end

      # Try to parse input into expression
      #
      # @param [String] input
      #
      # @return [Expression]
      #   if expression is valid
      #
      # @return [nil]
      #   otherwise
      def try_parse(input)
        expressions = expressions(input)
        case expressions.length
        when 0, 1
          expressions.first
        else
          fail AmbiguousExpressionError, "Ambiguous expression: #{input.inspect}"
        end
      end

    private

      # Expressions parsed from input
      #
      # @param [String] input
      #
      # @return [Array<Expression>]
      #   if expressions can be parsed from input
      def expressions(input)
        types.each_with_object([]) do |type, aggregate|
          expression = type.try_parse(input)
          aggregate << expression if expression
        end
      end

    end # Parser
  end # Expression
end # Mutant
