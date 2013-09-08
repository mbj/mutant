# encoding: utf-8

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

      # Return match expression
      #
      # @return [String]
      #
      # @api private
      #
      def match_expression
        "#{context.identification}#{self.class::SYMBOL}#{name}"
      end

    private

      # Return mutations
      #
      # @param [#<<] emitter
      #
      # @return [undefined]
      #
      # @api private
      #
      def generate_mutations(emitter)
        emitter << noop_mutation
        Mutator.each(node) do |mutant|
          emitter << Mutation::Evil.new(self, mutant)
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

    end # Method
  end # Subject
end # Mutant
