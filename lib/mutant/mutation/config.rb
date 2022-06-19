# frozen_string_literal: true

module Mutant
  class Mutation
    class Config
      include Anima.new(:timeout)

      DEFAULT = new(timeout: nil)

      TRANSFORM = Transform::Sequence.new(
        [
          Transform::Hash.new(
            optional: [
              Transform::Hash::Key.new('timeout', Transform::FLOAT)
            ],
            required: []
          ),
          Transform::Hash::Symbolize.new,
          Transform::Success.new(DEFAULT.method(:with))
        ]
      )

      def merge(other)
        with(
          timeout: other.timeout || timeout
        )
      end
    end # Config
  end # Mutation
end # Mutant
