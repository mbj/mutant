module Mutant
  class Matcher
    # Matcher for specific namespace
    class Scope < self
      include Concord::Public.new(:env, :scope, :expression)

      MATCHERS = [
        Matcher::Methods::Singleton,
        Matcher::Methods::Instance
      ].freeze

      # Return identification
      #
      # @return [String]
      #
      # @api private
      #
      def identification
        scope.name
      end
      memoize :identification

      # Enumerate subjects
      #
      # @return [self]
      #   if block given
      #
      # @return [Enumerator<Subject>]
      #   otherwise
      #
      # @api private
      #
      def each(&block)
        return to_enum unless block_given?

        MATCHERS.each do |matcher|
          matcher.new(env, scope).each(&block)
        end

        self
      end

    end # Scope
  end # Matcher
end # Mutant
