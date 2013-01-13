module Mutant
  class Killer
    # Runner for rspec tests
    class Rspec < self
      TYPE = 'rspec'.freeze

    private

      # Initialize rspec runner
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(*)
        @error_stream, @output_stream = StringIO.new, StringIO.new
        super
      end

      # Run rspec test
      #
      # @return [true]
      #   returns true when test is NOT successful and the mutant was killed
      #
      # @return [false]
      #   returns false otherwise
      #
      # @api private
      #
      def run
        mutation.insert
        !::RSpec::Core::Runner.run(command_line_arguments, strategy.error_stream, strategy.output_stream).zero?
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
