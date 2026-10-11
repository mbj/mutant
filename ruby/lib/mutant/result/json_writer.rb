# frozen_string_literal: true

module Mutant
  module Result
    # Write result JSON to .mutant/results/, gzip compressed
    class JSONWriter
      include Anima.new(:env, :result)

      # Log stored in place of the log of a covered mutation
      EMPTY_LOG = LogCapture::String.new(content: '')

      # Write result JSON file
      #
      # The JSON repeats the source, diff, and tests of each mutation,
      # and compresses about twentyfold.
      #
      # Written to a temporary file first and renamed into place, so a
      # concurrent reader of the session file never observes a partial
      # document. This matters once the file is rewritten during a run.
      #
      # @return [Pathname]
      def call
        dir = env.world.pathname.new(SessionFiles::DIRECTORY)
        dir.mkpath

        path = dir.join("#{SESSION_ID}.json.gz")
        tmp_path = dir.join("#{SESSION_ID}.json.gz.tmp")
        tmp_path.binwrite(Zlib.gzip(json))
        tmp_path.rename(path)

        path
      end

    private

      def json
        JSON.generate(Session::CODEC.dump(session).from_right)
      end

      def session
        Session.new(
          killtime:        result.killtime,
          mutant_version:  VERSION,
          pid:             env.world.process.pid,
          ruby_version:    RUBY_VERSION,
          runtime:         result.runtime,
          session_id:      SESSION_ID,
          subject_results: result.subject_results.map(&method(:without_covered_logs))
        )
      end

      def without_covered_logs(subject_result)
        subject_result.with(
          coverage_results: subject_result.coverage_results.map(&method(:without_log))
        )
      end

      # The log of a covered mutation is the output of the tests that
      # killed it. The session subcommands only report alive mutations,
      # so nothing reads it back, and on a suite whose failures print
      # large values it is most of the session file.
      def without_log(coverage_result)
        return coverage_result unless coverage_result.success?

        mutation_result = coverage_result.mutation_result

        coverage_result.with(
          mutation_result: mutation_result.with(
            isolation_result: mutation_result.isolation_result.with(log: EMPTY_LOG)
          )
        )
      end
    end # JSONWriter
  end # Result
end # Mutant
