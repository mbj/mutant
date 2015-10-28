module Mutant
  class Matcher
    # Matcher filter
    class Filter < self
      include Concord.new(:matcher, :predicate)

      # Enumerate matches
      #
      # @param [Env] env
      #
      # @return [Enumerable<Subject>]
      #
      # @api private
      def call(env)
        matcher
          .call(env)
          .select(&predicate.method(:call))
      end

    end # Filter
  end # Matcher
end # Mutant
