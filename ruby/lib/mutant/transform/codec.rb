# frozen_string_literal: true

module Mutant
  class Transform
    # Bidirectional codec over Ruby objects.
    #
    # Wraps a pair of dump/load transforms that convert between domain
    # objects and a JSON-compatible Ruby structure (hashes, arrays,
    # primitives). The outer layer that converts the structure to/from
    # a JSON string is handled by callers as needed.
    class Codec
      include Anima.new(:dump_transform, :load_transform)

      # Build a codec for simple Anima objects with primitive fields
      #
      # @param [Class] klass
      #
      # @return [Codec]
      def self.for_anima(klass)
        new(
          dump_transform: Success.new(block: ->(object) { object.to_h.transform_keys(&:to_s) }),
          load_transform: Success.new(block: ->(hash) { klass.new(**hash.transform_keys(&:to_sym)) })
        )
      end

      # Dump object to Ruby structure
      #
      # @param [Object] object
      #
      # @return [Either<Error, Object>]
      def dump(object)
        dump_transform.call(object)
      end

      # Load object from Ruby structure
      #
      # @param [Object] input
      #
      # @return [Either<Error, Object>]
      def load(input)
        load_transform.call(input)
      end
    end # Codec
  end # Transform
end # Mutant
