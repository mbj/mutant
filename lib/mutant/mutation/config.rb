# frozen_string_literal: true

module Mutant
  class Mutation
    class Config
      include Anima.new(:ignore_patterns, :timeout)

      DEFAULT = new(
        timeout:         nil,
        ignore_patterns: []
      )

      ignore_pattern = Transform::Block.capture('ignore pattern', &AST::Pattern.method(:parse))

      TRANSFORM = Transform::Sequence.new(
        [
          Transform::Hash.new(
            optional: [
              Transform::Hash::Key.new('ignore_patterns', Transform::Array.new(ignore_pattern)),
              Transform::Hash::Key.new('timeout',         Transform::FLOAT)
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
