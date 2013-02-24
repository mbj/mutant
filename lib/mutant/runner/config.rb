module Mutant
  class Runner
    # Runner for config
    class Config < self

      # Return subject runners
      #
      # @return [Enumerable<Runner::Subject>]
      #
      # @api private
      #
      attr_reader :subjects

    private

      def run
        @subjects = config.subjects.map do |subject|
          Subject.run(config, subject)
        end
      end

    end
  end
end
