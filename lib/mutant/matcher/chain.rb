# frozen_string_literal: true

module Mutant
  class Matcher
    # Matcher chaining results of other matchers together
    class Chain < self
      include Concord.new(:matchers)

      # Call matcher
      #
      # @param [Env::Bootstrap] env
      #
      # @return [Enumerable<Subject>]
      def call(env)
        matchers.flat_map do |matcher|
          matcher.call(env)
        end
      end

    end # Chain
  end # Matcher
end # Mutant
