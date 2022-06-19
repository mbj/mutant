# frozen_string_literal: true

module Mutant
  class Transform
    include Adamantium, AbstractType

    # Default slug
    #
    # @return [String]
    def slug
      self.class.to_s
    end

    # Apply transformation to input
    #
    # @param [Object] input
    #
    # @return [Either<Error, Object>]
    abstract_method :call

    # Deep error data structure
    class Error
      include Adamantium, Anima.new(
        :cause,
        :input,
        :message,
        :transform
      )

      COMPACT = '%<path>s: %<message>s'

      private_constant(*constants(false))

      # Compact error message
      #
      # @return [String]
      def compact_message
        COMPACT % { path: path, message: trace.last.message }
      end
      memoize :compact_message

      # Error path trace
      #
      # @return [Array<Error>]
      def trace
        [self, *cause&.trace]
      end
      memoize :trace

    private

      def path
        trace.map { |error| error.transform.slug }.reject(&:empty?).join('/')
      end
    end # Error

    # Wrapper adding a name to a transformation
    class Named < self
      include Concord.new(:name, :transformer)

      # Apply transformation to input
      #
      # @return [Either<Error, Object>]
      def call(input)
        transformer.call(input).lmap(&method(:wrap_error))
      end

      # Named slug
      #
      # @return [String]
      def slug
        name
      end
    end # Named

    class Block < self
      include Anima.new(:block, :name)

      def self.capture(name, &block)
        new(block: block, name: name)
      end

      def call(input)
        block
          .call(input)
          .lmap do |message|
            Error.new(
              cause:     nil,
              input:     input,
              message:   message,
              transform: self
            )
          end
      end

      def slug
        name
      end
    end

  private

    def error(cause: nil, input:, message: nil)
      Error.new(
        cause:     cause,
        input:     input,
        message:   message,
        transform: self
      )
    end

    def lift_error(error)
      error.with(transform: self)
    end

    def wrap_error(error)
      error(cause: error, input: error.input)
    end

    def failure(value)
      Either::Left.new(value)
    end

    def success(value)
      Either::Right.new(value)
    end

    # Index attached to a transform
    class Index < self
      include Anima.new(:index, :transform)

      private(*anima.attribute_names)

      # Create error at specified index
      #
      # @param [Error] cause
      # @param [Integer] index
      #
      # @return [Error]
      def self.wrap(cause, index)
        Error.new(
          cause:     cause,
          input:     cause.input,
          message:   nil,
          transform: new(index: index, transform: cause.transform)
        )
      end

      # Apply transformation to input
      #
      # @param [Object] input
      #
      # @return [Either<Error, Object>]
      def call(input)
        transform.call(input).lmap(&method(:wrap_error))
      end

      # Rendering slug
      #
      # @return [Array<String>]
      def slug
        '%<index>d' % { index: index }
      end
      memoize :slug
    end # Index

    # Transform guarding a specific primitive
    class Primitive < self
      include Concord.new(:primitive)

      MESSAGE = 'Expected: %<expected>s but got: %<actual>s'

      private_constant(*constants(false))

      # Apply transformation to input
      #
      # @param [Object] input
      #
      # @return [Either<Error, Object>]
      def call(input)
        if input.instance_of?(primitive)
          success(input)
        else
          failure(
            error(
              input:   input,
              message: MESSAGE % { actual: input.class, expected: primitive }
            )
          )
        end
      end

      # Rendering slug
      #
      # @return [String]
      def slug
        primitive.to_s
      end
      memoize :slug
    end # Primitive

    # Transform guarding boolean primitives
    class Boolean < self
      include Concord.new

      MESSAGE = 'Expected: boolean but got: %<actual>s'

      private_constant(*constants(false))

      # Apply transformation to input
      #
      # @param [Object] input
      #
      # @return [Either<Error, Object>]
      def call(input)
        if input.equal?(true) || input.equal?(false)
          success(input)
        else
          failure(
            error(
              message: MESSAGE % { actual: input.inspect },
              input:   input
            )
          )
        end
      end
    end # Boolean

    # Transform an array via mapping it over transform
    class Array < self
      include Concord.new(:transform)

      MESSAGE   = 'Failed to coerce array at index: %<index>d'
      PRIMITIVE = Primitive.new(::Array)

      private_constant(*constants(false))

      # Apply transformation to input
      #
      # @param [Object] input
      #
      # @return [Either<Error, Array<Object>>]
      def call(input)
        PRIMITIVE
          .call(input)
          .lmap(&method(:lift_error))
          .bind(&method(:run))
      end

    private

      # rubocop:disable Metrics/MethodLength
      def run(input)
        output = []

        input.each_with_index do |value, index|
          output << transform.call(value).lmap do |error|
            return failure(
              error(
                cause:   Index.wrap(error, index),
                message: MESSAGE % { index: index },
                input:   input
              )
            )
          end.from_right
        end

        success(output)
      end
      # rubocop:enable Metrics/MethodLength
    end # Array

    # Transform a hash via mapping it over key specific transforms
    class Hash < self
      include Anima.new(:optional, :required)

      KEY_MESSAGE = 'Missing keys: %<missing>s, Unexpected keys: %<unexpected>s'
      PRIMITIVE   = Primitive.new(::Hash)

      private_constant(*constants(false))

      # Transform to symbolize array keys
      class Symbolize < Transform
        # Apply transformation to input
        #
        # @param [Hash{String => Object}]
        #
        # @return [Hash{Symbol => Object}]
        def call(input)
          success(input.transform_keys(&:to_sym))
        end
      end # Symbolize

      # Key specific transformation
      class Key < Transform
        include Concord::Public.new(:value, :transform)

        # Rendering slug
        #
        # @return [String]
        def slug
          '[%<key>s]' % { key: value.inspect }
        end
        memoize :slug

        # Apply transformation to input
        #
        # @param [Object]
        #
        # @return [Either<Error, Object>]
        def call(input)
          transform.call(input).lmap do |error|
            error(cause: error, input: input)
          end
        end
      end # Key

      # Apply transformation to input
      #
      # @param [Object] input
      #
      # @return [Either<Error, Object>]
      def call(input)
        PRIMITIVE
          .call(input)
          .lmap(&method(:lift_error))
          .bind(&method(:reject_keys))
          .bind(&method(:transform))
      end

    private

      def transform(input)
        transform_required(input).bind do |required|
          transform_optional(input).fmap(&required.public_method(:merge))
        end
      end

      def transform_required(input)
        transform_keys(required, input)
      end

      def transform_optional(input)
        transform_keys(
          optional.select { |key| input.key?(key.value) },
          input
        )
      end

      # rubocop:disable Metrics/MethodLength
      def transform_keys(keys, input)
        success(
          keys
            .to_h do |key|
              [
                key.value,
                coerce_key(key, input).from_right do |error|
                  return failure(error)
                end
              ]
            end
        )
      end
      # rubocop:enable Metrics/MethodLength

      def coerce_key(key, input)
        key.call(input.fetch(key.value)).lmap do |error|
          error(input: input, cause: error)
        end
      end

      # rubocop:disable Metrics/MethodLength
      def reject_keys(input)
        keys       = input.keys
        unexpected = keys - allowed_keys
        missing    = required_keys - keys

        if unexpected.empty? && missing.empty?
          success(input)
        else
          failure(
            error(
              input:   input,
              message: KEY_MESSAGE % { missing: missing, unexpected: unexpected }
            )
          )
        end
      end
      # rubocop:enable Metrics/MethodLength

      def allowed_keys
        required_keys + optional.map(&:value)
      end
      memoize :allowed_keys

      def required_keys
        required.map(&:value)
      end
      memoize :required_keys
    end # Hash

    # Sequence of transformations
    class Sequence < self
      include Concord.new(:steps)

      # Apply transformation to input
      #
      # @param [Object]
      #
      # @return [Either<Error, Object>]
      def call(input)
        current = input

        steps.each_with_index do |step, index|
          current = step.call(current).from_right do |error|
            return failure(error(cause: Index.wrap(error, index), input: input))
          end
        end

        success(current)
      end
    end # Sequence

    # Always successful transformation
    class Success < self
      include Concord.new(:block)

      # Apply transformation to input
      #
      # @param [Object]
      #
      # @return [Either<Error, Object>]
      def call(input)
        success(block.call(input))
      end
    end # Sequence

    # Generic exception transformer
    class Exception < self
      include Concord.new(:error_class, :block)

      # Apply transformation to input
      #
      # @param [Object]
      #
      # @return [Either<Error, Object>]
      def call(input)
        Either
          .wrap_error(error_class) { block.call(input) }
          .lmap { |exception| error(input: input, message: exception.to_s) }
      end
    end # Exception

    BOOLEAN      = Transform::Boolean.new
    FLOAT        = Transform::Primitive.new(Float)
    INTEGER      = Transform::Primitive.new(Integer)
    STRING       = Transform::Primitive.new(String)
    STRING_ARRAY = Transform::Array.new(STRING)
  end # Transform
end # Mutant
