module Mutant
  class Runner
    # Simple runner for rspec tests
    class Rspec < Runner

      # Return error stream
      #
      # @return [StringIO]
      #
      # @api private
      #
      def error_stream
        StringIO.new
      end

      # Return output stream
      #
      # @return [StringIO]
      #
      # @api private
      #
      def output_stream
        StringIO.new
      end

    private

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
        !RSpec::Core::Runner.run(command_line,error_stream,output_stream).zero?
      end

      # Return command line
      #
      # @return [Array]
      #
      # @api private
      #
      def command_line
        %W(
          --fail-fast
        ) + Dir[filename_pattern]
      end

      # Return rspec filename pattern
      #
      # @return [String]
      #
      # @api private
      #
      # TODO: Add an option or be clever and only run affected specs.
      #
      def filename_pattern
        'spec/unit/**/*_spec.rb'
      end

      memoize :output_stream, :error_stream
    end
  end
end
