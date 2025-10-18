# frozen_string_literal: true

module Mutant
  class Matcher
    # Matcher returning subjects already known at its creation time
    class Static
      include Anima.new(:subjects)

      # Call matcher
      #
      # @return [Enumerable<Subject>]
      def call(_env)
        subjects
      end
    end # Static
  end # Matcher
end # Mutant
