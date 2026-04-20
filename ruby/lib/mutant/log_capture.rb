# frozen_string_literal: true

module Mutant
  # Captured log output from a worker or forked process.
  #
  # Raw worker log bytes may or may not be valid UTF-8 — they commonly contain
  # terminal control sequences emitted by test frameworks. This class preserves
  # those bytes unaltered for terminal emission while distinguishing UTF-8 text
  # from arbitrary bytes in the codec representation.
  class LogCapture
    include AbstractType, Anima.new(:content)

    # Build the appropriate subclass from raw bytes.
    #
    # Takes ownership of +bytes+; encoding is mutated in place.
    #
    # @param [::String] bytes
    #
    # @return [LogCapture]
    def self.from_binary(bytes)
      if bytes.force_encoding(Encoding::UTF_8).valid_encoding?
        String.new(content: bytes)
      else
        Binary.new(content: bytes.force_encoding(Encoding::ASCII_8BIT))
      end
    end

    # UTF-8 valid log capture
    class String < self
      TYPE = 'string'
    end

    # Non UTF-8 log capture, preserved as raw bytes
    class Binary < self
      TYPE = 'binary'
    end

    dump = Transform::Success.new(
      block: lambda do |object|
        case object
        when String
          { 'type' => String::TYPE, 'content' => object.content }
        when Binary
          { 'type' => Binary::TYPE, 'content' => [object.content].pack('m0') }
        end
      end
    )

    # Normalize legacy plain-string log representation into the tagged form.
    # Session JSON files written before LogCapture store +log+ and +output+
    # as plain strings; promote those to string-typed captures on load.
    legacy = Transform::Block.capture('log_capture_legacy') do |input|
      case input
      when ::String
        Either::Right.new('type' => String::TYPE, 'content' => input)
      else
        Either::Right.new(input)
      end
    end

    load = Transform::Sequence.new(
      steps: [
        legacy,
        Transform::Hash.new(
          required: [
            Transform::Hash::Key.new(value: 'type',    transform: Transform::STRING),
            Transform::Hash::Key.new(value: 'content', transform: Transform::STRING)
          ],
          optional: []
        ),
        Transform::Block.capture('log_capture') do |hash|
          type    = hash.fetch('type')
          content = hash.fetch('content')

          case type
          when String::TYPE
            Either::Right.new(String.new(content: content))
          when Binary::TYPE
            Either::Right.new(Binary.new(content: content.unpack1('m0').force_encoding(Encoding::ASCII_8BIT)))
          else
            Either::Left.new("Unknown log capture type: #{type.inspect}")
          end
        end
      ]
    )

    CODEC = Transform::Codec.new(dump_transform: dump, load_transform: load)
  end # LogCapture
end # Mutant
