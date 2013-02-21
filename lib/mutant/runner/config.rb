module Mutant
  class Runner
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
