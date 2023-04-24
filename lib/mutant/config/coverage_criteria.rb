# frozen_string_literal: true

module Mutant
  class Config
    # Configuration of coverge conditions
    class CoverageCriteria
      include Anima.new(:process_abort, :test_result, :timeout)

      EMPTY = new(
        process_abort: nil,
        test_result:   nil,
        timeout:       nil
      )

      DEFAULT = new(
        process_abort: false,
        test_result:   true,
        timeout:       false
      )

      TRANSFORM =
        Transform::Sequence.new(
          steps: [
            Transform::Hash.new(
              optional: [
                Transform::Hash::Key.new(
                  transform: Transform::BOOLEAN,
                  value:     'process_abort'
                ),
                Transform::Hash::Key.new(
                  transform: Transform::BOOLEAN,
                  value:     'test_result'
                ),
                Transform::Hash::Key.new(
                  transform: Transform::BOOLEAN,
                  value:     'timeout'
                )
              ],
              required: []
            ),
            Transform::Hash::Symbolize.new,
            ->(value) { Either::Right.new(DEFAULT.with(**value)) }
          ]
        )

      # Merge coverage criteria with other instance
      #
      # Values from the other instance have precedence.
      #
      # @param [CoverageCriteria] other
      #
      # @return [CoverageCriteria]
      def merge(other)
        self.class.new(
          process_abort: overwrite(other, :process_abort),
          test_result:   overwrite(other, :test_result),
          timeout:       overwrite(other, :timeout)
        )
      end

    private

      def overwrite(other, attribute_name)
        other_value = other.public_send(attribute_name)

        other_value.nil? ? public_send(attribute_name) : other_value
      end
    end # CoverageCriteria
  end # Config
end # Mutant
