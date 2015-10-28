module Mutant
  class Matcher
    # A null matcher, that does not match any subjects
    class Null < self
      include Concord.new

      # Enumerate subjects
      #
      # @param [Env] env
      #
      # @return [Enumerable<Subject>]
      #
      # @api private
      def call(_env)
        EMPTY_ARRAY
      end

    end # Null
  end # Matcher
end # Mutant
