# frozen_string_literal: true

module Mutant
  class Mutation
    class Config
      include Anima.new(
        :ignore_patterns,
        :operators,
        :timeout
      )

      EMPTY = new(
        ignore_patterns: [],
        operators:       nil,
        timeout:         nil
      )

      DEFAULT = new(
        ignore_patterns: [],
        operators:       Mutation::Operators::Light.new,
        timeout:         5.0
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
                transform: Operators::TRANSFORM,
                value:     'operators'
              ),
              Transform::Hash::Key.new(
                transform: Transform::FLOAT,
                value:     'timeout'
              )
            ],
            required: []
          ),
          Transform::Hash::Symbolize.new,
          Transform::Success.new(block: EMPTY.method(:with))
        ]
      )

      def merge(other)
        with(
          ignore_patterns: other.ignore_patterns.any? ? other.ignore_patterns : ignore_patterns,
          operators:       other.operators || operators,
          timeout:         other.timeout || timeout
        )
      end
    end # Config
  end # Mutation
end # Mutant
