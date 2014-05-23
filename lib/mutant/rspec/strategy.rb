# encoding: utf-8

module Mutant
  module Rspec

    # Rspec killer strategy
    class Strategy < Mutant::Strategy

      register 'rspec'

      # Setup rspec strategy
      #
      # @return [self]
      #
      # @api private
      #
      def setup
        output = StringIO.new
        configuration.error_stream = output
        configuration.output_stream = output
        options.configure(configuration)
        configuration.load_spec_files
        self
      end
      memoize :setup

      # Return new reporter
      #
      # @api private
      #
      def reporter
        reporter_class = RSpec::Core::Reporter

        if rspec2?
          reporter_class.new
        else
          reporter_class.new(configuration)
        end
      end

      # Detect RSpec 2
      #
      # @return [true]
      #   when RSpec 2
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def rspec2?
        RSpec::Core::Version::STRING.start_with?('2.')
      end

      # Return configuration
      #
      # @return [RSpec::Core::Configuration]
      #
      # @api private
      #
      def configuration
        RSpec::Core::Configuration.new
      end
      memoize :configuration, freezer: :noop

      # Return example groups
      #
      # @return [Enumerable<RSpec::Core::ExampleGroup>]
      #
      # @api private
      #
      def example_groups
        world.example_groups
      end

    private

      # Return world
      #
      # @return [RSpec::Core::World]
      #
      # @api private
      #
      def world
        RSpec.world
      end
      memoize :world, freezer: :noop

      # Return all available tests
      #
      # @return [Enumerable<Test>]
      #
      # @api private
      #
      def all_tests
        example_groups.map do |example_group|
          Test.new(self, example_group)
        end
      end

      # Return options
      #
      # @return [RSpec::Core::ConfigurationOptions]
      #
      # @api private
      #
      def options
        options = RSpec::Core::ConfigurationOptions.new(%w(--fail-fast spec))
        options.parse_options if rspec2?
        options
      end
      memoize :options, freezer: :noop

    end # Strategy
  end # Rspec
end # Mutant
