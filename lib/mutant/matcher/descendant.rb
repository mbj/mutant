# frozen_string_literal: true

module Mutant
  class Matcher
    # Matcher for descendants by constant name
    class Descendant < self
      include Anima.new(:const_name)

      def call(env)
        const = env.world.try_const_get(const_name) or return EMPTY_ARRAY

        Chain.new(
          matched_scopes(env, const).map { |scope| Scope.new(scope.raw) }
        ).call(env)
      end

    private

      def matched_scopes(env, const)
        env.matchable_scopes.select { |scope| const > scope.raw }
      end
    end # Descendant
  end # Matcher
end # Mutant
