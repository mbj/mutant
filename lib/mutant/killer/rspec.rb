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
        !run_rspec.zero?
      end
      memoize :run

      # Run rspec with some wired compat stuff
      #
      # @return [Fixnum]
      #   returns the exit status from rspec runner
      #
      # @api private
      #
      def run_rspec
        strategy.prepare_world
        ::RSpec::Core::Runner.run(command_line_arguments, @error_stream, @output_stream)
      end

      # Return command line arguments
      #
      # @return [Array]
      #
      # @api private
      #
      def command_line_arguments
        %W(
          --fail-fast
        ) + Dir[filename_pattern]
      end

      # Return filename pattern
      #
      # @return [String]
      #
      # @api private
      #
      def filename_pattern
        strategy.filename_pattern(mutation)
      end
    end
  end
end
