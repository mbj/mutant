module Mutant
  class Subject
    # Abstract base class for method subjects
    class Method < self

      # Test if method is public
      #
      # @return [true]
      #   if method is public
      #
      # @return [false]
      #   otherwise
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

    private

      # Return mutations
      #
      # @return [Enumerable<Mutation>]
      #
      # @api private
      #
      def mutations
        Mutator.each(node).map do |mutant|
          Mutation::Evil.new(self, mutant)
        end
      end

      # Return scope
      #
      # @return [Class, Module]
      #
      # @api private
      #
      def scope
        context.scope
      end

      # Return subtype identifier
      #
      # @return [String]
      #
      # @api private
      #
      def subtype
        "#{context.identification}#{self.class::SYMBOL}#{name}"
      end

    end # Method
  end # Subject
end # Mutant
