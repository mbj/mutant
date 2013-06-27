module Mutant
  class Matcher
    # Matcher for specific namespace
    class Scope < self
      include Concord::Public.new(:cache, :scope)

      MATCHERS = [
        Matcher::Methods::Singleton,
        Matcher::Methods::Instance
      ].freeze

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
          matcher.each(cache, scope, &block)
        end

        self
      end

    end # Scope
  end # Matcher
end # Mutant
