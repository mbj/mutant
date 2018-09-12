# frozen_string_literal: true

module Mutant
  class Subject
    # Abstract base class for method subjects
    class Method < self

      # Method name
      #
      # @return [Expression]
      def name
        node.children.fetch(self.class::NAME_INDEX)
      end

      # Match expression
      #
      # @return [String]
      def expression
        Expression::Method.new(
          method_name:  name.to_s,
          scope_symbol: self.class::SYMBOL,
          scope_name:   scope.name
        )
      end
      memoize :expression

      # Match expressions
      #
      # @return [Array<Expression>]
      def match_expressions
        [expression].concat(context.match_expressions)
      end
      memoize :match_expressions

    private

      # The scope
      #
      # @return [Class, Module]
      def scope
        context.scope
      end

    end # Method
  end # Subject
end # Mutant
