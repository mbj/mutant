module Mutant
  class Matcher
    # A chain of matchers
    class Chain < self
      include Concord::Public.new(:matchers)

      # Enumerate subjects
      #
      # @return [Enumerator<Subject]
      #   if no block given
      #
      # @return [self]
      #   otherwise
      #
      # @api private
      #
      def each(&block)
        return to_enum unless block_given?

        matchers.each do |matcher|
          matcher.each(&block)
        end

        self
      end

    end # Chain
  end # Matcher
end # Mutant
