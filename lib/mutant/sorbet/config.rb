# frozen_string_literal: true

module Mutant
  module Sorbet
    # Configuration for Sorbet type checking integration
    class Config
      include Adamantium, Anima.new(:enabled, :timeout, :binary, :cache_dir)

      DEFAULT = new(
        binary:    nil,   # Auto-detect
        cache_dir: nil,   # Auto-detect: tmp/sorbet-cache
        enabled:   false, # Opt-in
        timeout:   5.0    # seconds
      )

      TRANSFORM = Transform::Sequence.new(
        steps: [
          Transform::Primitive.new(primitive: Hash),
          Transform::Hash.new(
            optional: [
              Transform::Hash::Key.new(
                transform: Transform::BOOLEAN,
                value:     'enabled'
              ),
              Transform::Hash::Key.new(
                transform: Transform::FLOAT,
                value:     'timeout'
              ),
              Transform::Hash::Key.new(
                transform: Transform::STRING,
                value:     'binary'
              ),
              Transform::Hash::Key.new(
                transform: Transform::STRING,
                value:     'cache_dir'
              )
            ],
            required: []
          ),
          Transform::Hash::Symbolize.new,
          Transform::Success.new(block: DEFAULT.method(:with))
        ]
      )

      def merge(other)
        self.class.new(
          binary:    other.binary || binary,
          cache_dir: other.cache_dir || cache_dir,
          enabled:   other.enabled || enabled,
          timeout:   other.timeout
        )
      end

      def enabled?
        enabled
      end
    end
  end
end
