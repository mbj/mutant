# frozen_string_literal: true

module Mutant
  class Expression
    class Parser
      include Anima.new(:types)

      # Parse expression
      #
      # @param [String] input
      #
      # @return [Either<String, Expression>]
      #   if expression is valid
      #
      # @return [nil]
      #   otherwise
      def call(input)
        case expressions(input)
        in []
          Either::Left.new("Expression: #{input.inspect} is invalid")
        in [expression]
          Either::Right.new(expression)
        else
          Either::Left.new("Expression: #{input.inspect} is ambiguous")
        end
      end

    private

      def expressions(input)
        types.each_with_object([]) do |type, aggregate|
          expression = type.try_parse(input) and aggregate << expression
        end
      end

    end # Parser
  end # Expression
end # Mutant
