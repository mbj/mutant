module Mutant
  class Matcher
    # Matcher chaining results of other matchers together
    class Chain < self
      include Concord.new(:matchers)

      # Call matcher
      #
      # @param [Env] env
      #
      # @return [Enumerable<Subject>]
      #
      # @api private
      def call(env)
        matchers.flat_map do |matcher|
          matcher.call(env)
        end
      end

    end # Chain
  end # Matcher
end # Mutant
