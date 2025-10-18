# frozen_string_literal: true

module Mutant
  class Matcher
    # Matcher for specific namespace
    class Namespace < self
      include Anima.new(:expression)

      # Enumerate subjects
      #
      # @param [Env] env
      #
      # @return [Enumerable<Subject>]
      def call(env)
        Chain.new(
          matchers: matched_scopes(env).map { |scope| Scope.new(scope:) }
        ).call(env)
      end

    private

      def matched_scopes(env)
        env
          .matchable_scopes
          .select(&method(:match?))
      end

      def match?(scope)
        expression.prefix?(scope.expression)
      end

    end # Namespace
  end # Matcher
end # Mutant
