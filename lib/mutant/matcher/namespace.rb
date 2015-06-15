module Mutant
  class Matcher

    # Matcher for specific namespace
    class Namespace < self
      include Concord::Public.new(:env, :expression)

      # Enumerate subjects
      #
      # @return [self]
      #   if block given
      #
      # @return [Enumerator<Subject>]
      #   otherwise
      #
      # @api private
      #
      def each(&block)
        return to_enum unless block_given?

        env.matchable_scopes.select do |scope|
          scope.each(&block) if match?(scope)
        end

        self
      end

    private

      # Test scope if name matches expression
      #
      # @param [Module, Class] scope
      #
      # @return [Boolean]
      #
      # @api private
      #
      def match?(scope)
        expression.prefix?(scope.expression)
      end

    end # Namespace
  end # Matcher
end # Mutant
