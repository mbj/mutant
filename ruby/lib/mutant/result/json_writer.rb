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
          subject_results: result.subject_results
        )
      end
    end # JSONWriter
  end # Result
end # Mutant
