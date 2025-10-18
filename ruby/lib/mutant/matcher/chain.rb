# frozen_string_literal: true

module Mutant
  class Matcher
    # Matcher chaining results of other matchers together
    class Chain < self
      include Anima.new(:matchers)

      # Call matcher
      #
      # @param [Env] env
      #
      # @return [Enumerable<Subject>]
      def call(env)
        matchers.flat_map do |matcher|
          matcher.call(env)
        end.uniq
      end

    end # Chain
  end # Matcher
end # Mutant
