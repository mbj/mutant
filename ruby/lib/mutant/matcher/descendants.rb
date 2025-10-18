# frozen_string_literal: true

module Mutant
  class Matcher
    # Matcher for all descendants by constant name
    class Descendants < self
      include Anima.new(:const_name)

      def call(env)
        const = env.world.try_const_get(const_name) or return EMPTY_ARRAY

        Chain.new(
          matchers: matched_scopes(env, const).map { |scope| Scope.new(scope:) }
        ).call(env)
      end

    private

      def matched_scopes(env, const)
        env.matchable_scopes.select do |scope|
          scope.raw.equal?(const) || const > scope.raw
        end
      end
    end # Descendant
  end # Matcher
end # Mutant
