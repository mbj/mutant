# frozen_string_literal: true

module Mutant
  class Matcher
    # Matcher expanding Mutant::Scope objects into method matches
    # at singleton or instance level
    #
    # If we *ever* get other subjects than methods, its likely the place
    # to hook in custom matchers. In that case the scope matchers to expand
    # should be passed as arguments to the constructor.
    class Scope < self
      include Anima.new(:scope)

      MATCHERS = [
        Matcher::Methods::Singleton,
        Matcher::Methods::Instance,
        Matcher::Methods::Metaclass
      ].freeze

      private_constant(*constants(false))

      # Matched subjects
      #
      # @param [Env] env
      #
      # @return [Enumerable<Subject>]
      def call(env)
        Chain.new(matchers: effective_matchers).call(env)
      end

    private

      def effective_matchers
        MATCHERS.map { |matcher| matcher.new(scope: scope) }
      end

    end # Scope
  end # Matcher
end # Mutant
