# frozen_string_literal: true

module Mutant
  class Matcher
    # A null matcher, that does not match any subjects
    class Null < self
      include Concord.new

      # Enumerate subjects
      #
      # @param [Env::Bootstrap] env
      #
      # @return [Enumerable<Subject>]
      def call(_env)
        EMPTY_ARRAY
      end

    end # Null
  end # Matcher
end # Mutant
