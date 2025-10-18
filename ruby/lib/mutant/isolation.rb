# frozen_string_literal: true

module Mutant
  # Isolation mechanism
  class Isolation
    include AbstractType

    # Isolated computation result
    class Result
      include Anima.new(
        :exception,
        :log,
        :process_status,
        :timeout,
        :value
      )

      # Test for successful result
      #
      # @return [Boolean]
      def valid_value?
        timeout.nil? && exception.nil? && (process_status.nil? || process_status.success?)
      end
    end # Result

    # Call block in isolation
    #
    # @return [Result]
    #   the blocks result
    abstract_method :call
  end # Isolation
end # Mutant
