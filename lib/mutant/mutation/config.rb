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
        steps: [
          Transform::Hash.new(
            optional: [
              Transform::Hash::Key.new(
                transform: Transform::Array.new(transform: ignore_pattern),
                value:     'ignore_patterns'
              ),
              Transform::Hash::Key.new(
                transform: Transform::FLOAT,
                value:     'timeout'
              )
            ],
            required: []
          ),
          Transform::Hash::Symbolize.new,
          Transform::Success.new(block: DEFAULT.method(:with))
        ]
      )

      def merge(other)
        with(
          ignore_patterns: other.ignore_patterns,
          timeout:         other.timeout || timeout
        )
      end
    end # Config
  end # Mutation
end # Mutant
