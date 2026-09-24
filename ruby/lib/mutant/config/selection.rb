# frozen_string_literal: true

module Mutant
  class Config
    # Configuration of how tests get selected for a subject
    class Selection
      include Adamantium, Anima.new(:path, :strategy)

      # Use the coverage recording when there is one, and the expressions
      # otherwise. Mutant's default.
      AUTO = 'auto'

      # Select tests whose expressions match the subject's
      EXPRESSION = 'expression'

      # Select tests a coverage recording says executed the subject's lines
      CONTEXT_MAP = 'context_map'

      STRATEGIES = [AUTO, EXPRESSION, CONTEXT_MAP].freeze

      # Directory coverage tools write their report into
      DEFAULT_PATH = 'coverage'

      UNKNOWN_STRATEGY = 'Unknown test selection strategy %s, expected one of: %s'

      private_constant(:UNKNOWN_STRATEGY)

      # Both attributes stay nil until set, so a value from mutant.yml is not
      # overwritten by a default coming from the CLI end of the merge.
      DEFAULT = new(path: nil, strategy: nil)

      TRANSFORM =
        Transform::Sequence.new(
          steps: [
            Transform::Hash.new(
              optional: [
                Transform::Hash::Key.new(
                  transform: Transform::STRING,
                  value:     'path'
                ),
                Transform::Hash::Key.new(
                  transform: Transform::STRING,
                  value:     'strategy'
                )
              ],
              required: []
            ),
            Transform::Hash::Symbolize.new,
            Transform::Block.capture(:selection) { |value| new(**DEFAULT.to_h, **value).validate }
          ]
        )

      # Whether the recording is the only acceptable source of tests
      #
      # @return [Boolean]
      def context_map? = strategy.eql?(CONTEXT_MAP)

      # Whether the expressions are the only acceptable source of tests
      #
      # @return [Boolean]
      def expression? = strategy.eql?(EXPRESSION)

      # The configured recording location, or the conventional one
      #
      # @return [String]
      def effective_path = path || DEFAULT_PATH

      # Reject a strategy mutant does not implement
      #
      # @return [Either<String, Selection>]
      def validate
        return Either::Right.new(self) if strategy.nil? || STRATEGIES.include?(strategy)

        Either::Left.new(UNKNOWN_STRATEGY % [strategy.inspect, STRATEGIES.join(', ')])
      end

      # Merge with other selection config
      #
      # Values from the other instance have precedence.
      #
      # @param [Selection] other
      #
      # @return [Selection]
      def merge(other)
        self.class.new(
          path:     other.path || path,
          strategy: other.strategy || strategy
        )
      end
    end # Selection
  end # Config
end # Mutant
