# frozen_string_literal: true

module Mutant
  module Result
    # Top-level result object containing session metadata and subject results
    class Session
      # Extract timestamp from UUIDv7 session_id
      module Timestamp
        # @return [Time]
        def timestamp
          ms = session_id.delete('-')[0, 12].to_i(16)
          Time.at(ms / 1000.0).utc
        end
      end

      include Timestamp, Anima.new(
        :killtime,
        :mutant_version,
        :pid,
        :ruby_version,
        :runtime,
        :session_id,
        :subject_results
      )

      dump = Transform::Success.new(
        block: lambda do |object|
          {
            'killtime'        => object.killtime,
            'mutant_version'  => object.mutant_version,
            'pid'             => object.pid,
            'ruby_version'    => object.ruby_version,
            'runtime'         => object.runtime,
            'session_id'      => object.session_id,
            'subject_results' => object.subject_results.map { |subject_result| Subject::CODEC.dump(subject_result).from_right }
          }
        end
      )

      load = Transform::Sequence.new(
        steps: [
          Transform::Hash.new(
            required: [
              Transform::Hash::Key.new(value: 'killtime',        transform: Transform::FLOAT),
              Transform::Hash::Key.new(value: 'mutant_version',  transform: Transform::STRING),
              Transform::Hash::Key.new(value: 'pid',             transform: Transform::INTEGER),
              Transform::Hash::Key.new(value: 'ruby_version',    transform: Transform::STRING),
              Transform::Hash::Key.new(value: 'runtime',         transform: Transform::FLOAT),
              Transform::Hash::Key.new(value: 'session_id',      transform: Transform::STRING),
              Transform::Hash::Key.new(value: 'subject_results', transform: Transform::Array.new(transform: Subject::CODEC.load_transform))
            ],
            optional: []
          ),
          Transform::Hash::Symbolize.new,
          Transform::Success.new(block: method(:new).to_proc)
        ]
      )

      CODEC = Transform::Codec.new(dump_transform: dump, load_transform: load)

    end # Session
  end # Result
end # Mutant
