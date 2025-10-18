# frozen_string_literal: true

module Mutant
  # Module providing isolation
  class Isolation
    # Absolutely no isolation
    #
    # Only useful for debugging.
    class None < self

      # Call block in no isolation
      #
      # @return [Result]
      #
      # rubocop:disable Lint/SuppressedException
      # rubocop:disable Metrics/MethodLength
      # ^^ it actually isn not suppressed, it assigns an lvar
      def call(_timeout)
        begin
          value = yield
        rescue => exception
        end

        Result.new(
          exception:,
          log:            '',
          process_status: nil,
          timeout:        nil,
          value:
        )
      end
      # rubocop:enable Lint/SuppressedException
      # rubocop:enable Metrics/MethodLength

    end # None
  end # Isolation
end # Mutant
