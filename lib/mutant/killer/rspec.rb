module Mutant
  class Killer
    # Simple runner for rspec tests
    class Rspec < self

      # Return error stream
      #
      # @return [StringIO]
      #
      # @api private
      #
      attr_reader :error_stream

      # Return output stream
      #
      # @return [StringIO]
      #
      # @api private
      #
      attr_reader :output_stream

      # Run block in clean rspec environment
      #
      # @return [self]
      #
      # @api private
      #
      def self.nest
        original_world, original_configuration = 
          ::RSpec.instance_variable_get(:@world),
          ::RSpec.instance_variable_get(:@configuration)

        ::RSpec.instance_variable_set(:@world,nil)
        ::RSpec.instance_variable_set(:@configuration,nil)

        yield

        self
      ensure
        ::RSpec.instance_variable_set(:@world,original_world)
        ::RSpec.instance_variable_set(:@configuration,original_configuration)
      end

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
        !RSpec::Core::Runner.run(command_line_arguments, error_stream, output_stream).zero?
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
    end
  end
end
