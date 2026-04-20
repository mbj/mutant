# frozen_string_literal: true

module Mutant
  module Result
    # Write result JSON to .mutant/results/
    class JSONWriter
      include Anima.new(:env, :result)

      RESULTS_DIR = '.mutant/results'

      # Write result JSON file
      #
      # @return [Pathname]
      def call
        dir = env.world.pathname.new(RESULTS_DIR)
        dir.mkpath

        path = dir.join("#{SESSION_ID}.json")
        path.write(json)

        path
      end

    private

      def json
        JSON.generate(scrub_encoding(Session::JSON.dump(session).from_right))
      end

      # Ensure all strings are valid UTF-8 before JSON serialization.
      #
      # Strings captured from child process pipes (see Isolation::Fork) arrive
      # tagged as ASCII-8BIT. The json gem accepts those when the bytes happen
      # to be valid UTF-8 but raises JSON::GeneratorError otherwise (e.g. when
      # a multi-byte character split by a read boundary lands as a truncated
      # sequence). Re-tag as UTF-8 and scrub any genuinely invalid byte
      # sequences with U+FFFD.
      def scrub_encoding(object)
        case object
        when String
          object.dup.force_encoding(Encoding::UTF_8).scrub
        when Hash
          object.transform_values { |value| scrub_encoding(value) }
        when Array
          object.map { |element| scrub_encoding(element) }
        else
          object
        end
      end

      def session
        Session.new(
          killtime:        result.killtime,
          mutant_version:  VERSION,
          pid:             env.world.process.pid,
          ruby_version:    RUBY_VERSION,
          runtime:         result.runtime,
          session_id:      SESSION_ID,
          subject_results: result.subject_results
        )
      end
    end # JSONWriter
  end # Result
end # Mutant
