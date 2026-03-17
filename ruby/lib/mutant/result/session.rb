# frozen_string_literal: true

module Mutant
  module Result
    # Top-level result object containing session metadata and subject results
    class Session
      include Anima.new(
        :mutant_version,
        :pid,
        :ruby_version,
        :session_id,
        :subject_results
      )

      dump = Transform::Success.new(
        block: lambda do |object|
          {
            'mutant_version'  => object.mutant_version,
            'pid'             => object.pid,
            'ruby_version'    => object.ruby_version,
            'session_id'      => object.session_id,
            'subject_results' => object.subject_results.map { |sr| Subject::JSON.dump(sr).from_right }
          }
        end
      )

      load = Transform::Sequence.new(
        steps: [
          Transform::Hash.new(
            required: [
              Transform::Hash::Key.new(value: 'mutant_version',  transform: Transform::STRING),
              Transform::Hash::Key.new(value: 'pid',             transform: Transform::INTEGER),
              Transform::Hash::Key.new(value: 'ruby_version',    transform: Transform::STRING),
              Transform::Hash::Key.new(value: 'session_id',      transform: Transform::STRING),
              Transform::Hash::Key.new(value: 'subject_results', transform: Transform::Array.new(transform: Subject::JSON.load_transform))
            ],
            optional: []
          ),
          Transform::Hash::Symbolize.new,
          Transform::Success.new(block: method(:new).to_proc)
        ]
      )

      JSON = Transform::JSON.new(dump_transform: dump, load_transform: load)

      # Extract timestamp from UUIDv7 session_id
      #
      # @return [Time]
      def timestamp
        ms = session_id.delete('-')[0, 12].to_i(16)
        Time.at(ms / 1000.0).utc
      end
    end # Session
  end # Result
end # Mutant
