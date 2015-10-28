module Mutant
  class Matcher
    # Matcher for specific namespace
    class Namespace < self
      include Concord::Public.new(:expression)

      # Enumerate subjects
      #
      # @param [Env] env
      #
      # @return [Enumerable<Subject>]
      #
      # @api private
      def call(env)
        Chain.new(
          matched_scopes(env).map { |scope| Scope.new(scope.raw) }
        ).call(env)
      end

    private

      # The matched scopes
      #
      # @param [Env] env
      #
      # @return [Enumerable<Scope>]
      #
      # @api private
      def matched_scopes(env)
        env
          .matchable_scopes
          .select(&method(:match?))
      end

      # Test scope if matches expression
      #
      # @param [Scope] scope
      #
      # @return [Boolean]
      #
      # @api private
      def match?(scope)
        expression.prefix?(scope.expression)
      end

    end # Namespace
  end # Matcher
end # Mutant
