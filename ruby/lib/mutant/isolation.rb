# frozen_string_literal: true

module Mutant
  # Isolation mechanism
  class Isolation
    include AbstractType

    # Isolated computation result
    class Result
      include Anima.new(
        :exception,
        :log,
        :process_status,
        :timeout,
        :value
      )

      # Test for successful result
      #
      # @return [Boolean]
      def valid_value?
        timeout.nil? && exception.nil? && (process_status.nil? || process_status.success?)
      end

      dump = Transform::Success.new(
        block: lambda do |object|
          {
            'exception'      => object.exception && Mutant::Result::Exception::CODEC.dump(object.exception).from_right,
            'log'            => LogCapture::CODEC.dump(object.log).from_right,
            'process_status' => object.process_status && Mutant::Result::ProcessStatus::CODEC.dump(object.process_status).from_right,
            'timeout'        => object.timeout,
            'value'          => object.value && Mutant::Result::Test::CODEC.dump(object.value).from_right
          }
        end
      )

      load = Transform::Sequence.new(
        steps: [
          Transform::Hash.new(
            required: [
              Transform::Hash::Key.new(value: 'exception',      transform: Transform::Nullable.new(transform: Mutant::Result::Exception::CODEC.load_transform)),
              Transform::Hash::Key.new(value: 'log',            transform: LogCapture::CODEC.load_transform),
              Transform::Hash::Key.new(value: 'process_status', transform: Transform::Nullable.new(transform: Mutant::Result::ProcessStatus::CODEC.load_transform)),
              Transform::Hash::Key.new(value: 'timeout',        transform: Transform::Nullable.new(transform: Transform::FLOAT)),
              Transform::Hash::Key.new(value: 'value',          transform: Transform::Nullable.new(transform: Mutant::Result::Test::CODEC.load_transform))
            ],
            optional: []
          ),
          Transform::Hash::Symbolize.new,
          Transform::Success.new(block: method(:new).to_proc)
        ]
      )

      CODEC = Transform::Codec.new(dump_transform: dump, load_transform: load)
    end # Result

    # Call block in isolation
    #
    # @return [Result]
    #   the blocks result
    abstract_method :call
  end # Isolation
end # Mutant
