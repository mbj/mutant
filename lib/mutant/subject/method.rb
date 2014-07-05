module Mutant
  class Subject
    # Abstract base class for method subjects
    class Method < self

      # Test if method is public
      #
      # @return [Boolean]
      #
      # @api private
      #
      abstract_method :public?

      # Return method name
      #
      # @return [Symbol]
      #
      # @api private
      #
      def name
        node.children[self.class::NAME_INDEX]
      end

      # Return match expression
      #
      # @return [String]
      #
      # @api private
      #
      def expression
        Expression.parse("#{context.identification}#{self.class::SYMBOL}#{name}")
      end
      memoize :expression

    private

      # Return scope
      #
      # @return [Class, Module]
      #
      # @api private
      #
      def scope
        context.scope
      end

    end # Method
  end # Subject
end # Mutant
