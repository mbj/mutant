# frozen_string_literal: true

module Mutant
  class Transform
    # Bidirectional JSON transform
    #
    # Wraps a pair of dump/load transforms and optionally adds
    # JSON string serialization via .build
    class JSON
      include Anima.new(:dump_transform, :load_transform)

      # Build a JSON transform that wraps raw transforms with JSON.parse/generate
      #
      # @param [Transform] dump
      # @param [Transform] load
      #
      # @return [JSON]
      # rubocop:disable Metrics/MethodLength
      def self.build(dump:, load:)
        new(
          dump_transform: Sequence.new(
            steps: [
              dump,
              Success.new(block: ::JSON.public_method(:generate))
            ]
          ),
          load_transform: Sequence.new(
            steps: [
              Exception.new(error_class: ::JSON::ParserError, block: ::JSON.public_method(:parse)),
              load
            ]
          )
        )
      end
      # rubocop:enable Metrics/MethodLength

      # Build a JSON transform for simple Anima objects with JSON-primitive fields
      #
      # @param [Class] klass
      #
      # @return [JSON]
      def self.for_anima(klass)
        new(
          dump_transform: Success.new(block: ->(object) { object.to_h.transform_keys(&:to_s) }),
          load_transform: Success.new(block: ->(hash) { klass.new(**hash.transform_keys(&:to_sym)) })
        )
      end

      # Dump object to hash or JSON string
      #
      # @param [Object] object
      #
      # @return [Either<Error, Object>]
      def dump(object)
        dump_transform.call(object)
      end

      # Load object from hash or JSON string
      #
      # @param [Object] input
      #
      # @return [Either<Error, Object>]
      def load(input)
        load_transform.call(input)
      end
    end # JSON
  end # Transform
end # Mutant
