# frozen_string_literal: true

module Mutant
  # Module providing isolation
  class Isolation
    # Absolutly no isolation
    #
    # Only useful for debugging.
    class None < self

      # Call block in no isolation
      #
      # @return [Result]
      #
      # ignore :reek:UtilityFunction
      def call
        Result::Success.new(yield)
      rescue => exception
        Result::Exception.new(exception)
      end

    end # None
  end # Isolation
end # Mutant
