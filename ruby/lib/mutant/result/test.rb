# frozen_string_literal: true

module Mutant
  module Result
    # Test result
    class Test
      include Anima.new(:job_index, :passed, :runtime, :output)

      alias_method :success?, :passed

      class VoidValue < self
        include Singleton

        # Initialize object
        #
        # @return [undefined]
        def initialize
          super(
            job_index: nil,
            output:    LogCapture.from_binary(+''),
            passed:    false,
            runtime:   0.0
          )
        end
      end # VoidValue

      dump = Transform::Success.new(
        block: lambda do |object|
          {
            'job_index' => object.job_index,
            'output'    => LogCapture::CODEC.dump(object.output).from_right,
            'passed'    => object.passed,
            'runtime'   => object.runtime
          }
        end
      )

      load = Transform::Sequence.new(
        steps: [
          Transform::Hash.new(
            required: [
              Transform::Hash::Key.new(value: 'job_index', transform: Transform::Nullable.new(transform: Transform::INTEGER)),
              Transform::Hash::Key.new(value: 'output',    transform: LogCapture::CODEC.load_transform),
              Transform::Hash::Key.new(value: 'passed',    transform: Transform::BOOLEAN),
              Transform::Hash::Key.new(value: 'runtime',   transform: Transform::FLOAT)
            ],
            optional: []
          ),
          Transform::Hash::Symbolize.new,
          Transform::Success.new(block: method(:new).to_proc)
        ]
      )

      CODEC = Transform::Codec.new(dump_transform: dump, load_transform: load)
    end # Test
  end # Result
end # Mutant
