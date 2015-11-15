module Mutant
  class Matcher
    # Matcher expanding Mutant::Scope objects into method matches
    # at singleton or instance level
    #
    # If we *ever* get other subjects than methods, its likely the place
    # to hook in custom matchers. In that case the scope matchers to expand
    # should be passed as arguments to the constructor.
    class Scope < self
      include Concord.new(:scope)

      MATCHERS = [
        Matcher::Methods::Singleton,
        Matcher::Methods::Instance
      ].freeze

      private_constant(*constants(false))

      # Matched subjects
      #
      # @param [Env::Bootstrap] env
      #
      # @return [Enumerable<Subject>]
      def call(env)
        Chain.new(effective_matchers).call(env)
      end

    private

      # Effective matchers
      #
      # @return [Enumerable<Matcher>]
      def effective_matchers
        MATCHERS.map { |matcher| matcher.new(scope) }
      end

    end # Scope
  end # Matcher
end # Mutant
