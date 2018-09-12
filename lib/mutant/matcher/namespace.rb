# frozen_string_literal: true

module Mutant
  class Matcher
    # Matcher for specific namespace
    class Namespace < self
      include Concord::Public.new(:expression)

      # Enumerate subjects
      #
      # @param [Env::Bootstrap] env
      #
      # @return [Enumerable<Subject>]
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
      def match?(scope)
        expression.prefix?(scope.expression)
      end

    end # Namespace
  end # Matcher
end # Mutant
