module Mutant
  class Killer
    # Runner for rspec tests
    class Rspec < self

      TYPE = 'rspec'.freeze

    private

      # Run rspec test
      #
      # @return [true]
      #   when test is NOT successful and the mutant was killed
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def run
        mutation.insert
        !!::RSpec::Core::Runner.run(command_line_arguments, strategy.error_stream, strategy.output_stream).nonzero?
      end
      memoize :run

      # Return command line arguments
      #
      # @return [Array]
      #
      # @api private
      #
      def command_line_arguments
        %W(
          --fail-fast
        ) + strategy.spec_files(mutation.subject)
      end
    end
  end
end
