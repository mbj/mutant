module Mutant
  class Killer
    # Runner for rspec tests
    class Rspec < self

      # Run block in clean rspec environment
      #
      # @return [Object]
      #   returns the value of block
      #
      # @api private
      #
      def self.nest
        original_world, original_configuration = 
          ::RSpec.instance_variable_get(:@world),
          ::RSpec.instance_variable_get(:@configuration)

        ::RSpec.reset

        yield
      ensure
        ::RSpec.instance_variable_set(:@world, original_world)
        ::RSpec.instance_variable_set(:@configuration, original_configuration)
      end

      # Return identification
      #
      # @return [String]
      #
      # @api private
      # 
      def identification
        "rspec:#{mutation.identification}"
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
        !run_rspec.zero?
      end

      # Run rspec with some wired compat stuff
      #
      # FIXME: This extra stuff needs to be configurable per project
      #
      # @return [Fixnum]
      #   returns the exit status from rspec runner
      #
      # @api private
      #
      def run_rspec
        require 'rspec'
        self.class.nest do 
          require './spec/spec_helper.rb'
          if RSpec.world.shared_example_groups.empty?
            Dir['spec/{support,shared}/**/*.rb'].each { |f| load(f) }
          end
          ::RSpec::Core::Runner.run(command_line_arguments, @error_stream, @output_stream)
        end
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

      class Forking < self
        # Run rspec in subprocess
        #
        # @return [Fixnum]
        #   returns the exit status from rspec runner
        #
        # @api private
        #
        def run_rspec
          fork do
            exit run_rspec
          end
          pid, status = Process.wait2
          status.exitstatus
        end
      end
    end
  end
end
