module Mutant
  class Subject
    # Abstract base class for method subjects
    class Method < self

      # Method name
      #
      # @return [Expression]
      #
      # @api private
      def name
        node.children.fetch(self.class::NAME_INDEX)
      end

      # Match expression
      #
      # @return [String]
      #
      # @api private
      def expression
        Expression::Method.new(
          scope_symbol: self.class::SYMBOL,
          scope_name:   scope.name,
          method_name:  name.to_s
        )
      end
      memoize :expression

      # Match expressions
      #
      # @return [Array<Expression>]
      #
      # @api private
      def match_expressions
        [expression].concat(context.match_expressions)
      end
      memoize :match_expressions

    private

      # The scope
      #
      # @return [Class, Module]
      #
      # @api private
      def scope
        context.scope
      end

    end # Method
  end # Subject
end # Mutant
