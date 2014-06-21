module Mutant
  module Rspec

    # Rspec killer strategy
    class Strategy < Mutant::Strategy

      RSPEC_2_VERSION_PREFIX = '2.'.freeze

      register 'rspec'

      # Setup rspec strategy
      #
      # @return [self]
      #
      # @api private
      #
      def setup
        options.configure(configuration)
        configuration.load_spec_files
        self
      end
      memoize :setup

      # Test for rspec2
      #
      # @return [Boolean]
      #
      # @api private
      #
      def rspec2?
        RSpec::Core::Version::STRING.start_with?(RSPEC_2_VERSION_PREFIX)
      end

      # Return report for test
      #
      # @param [Rspec::Test] test
      #
      # @api private
      #
      def run(test)
        output = StringIO.new
        success = false
        reporter = new_reporter(output)
        reporter.report(1) do
          success = test.example_group.run(reporter)
        end
        output.rewind
        Test::Report.new(
          test:    self,
          output:  output.read,
          success: success
        )
      end

      # Return all available tests
      #
      # @return [Enumerable<Test>]
      #
      # @api private
      #
      def all_tests
        example_groups
          .flat_map(&:descendants)
          .map do |example_group|
            Test.new(self, example_group)
          end.select do |test|
            test.identification.split(' ', 2).first.eql?(test.identification)
          end
      end
      memoize :all_tests

    private

      # Return example groups
      #
      # @return [Enumerable<RSpec::Core::ExampleGroup>]
      #
      # @api private
      #
      def example_groups
        RSpec.world.example_groups
      end

      # Return new reporter
      #
      # @param [StringIO] output
      #
      # @return [RSpec::Core::Reporter]
      #
      # @api private
      #
      def new_reporter(output)
        reporter_class = RSpec::Core::Reporter

        # rspec3 does not require that one via a very indirect autoload setup
        require 'rspec/core/formatters/base_text_formatter'
        formatter = RSpec::Core::Formatters::BaseTextFormatter.new(output)

        if rspec2?
          reporter_class.new(formatter)
        else
          notifications = RSpec::Core::Formatters::Loader.allocate.send(:notifications_for, formatter.class)
          reporter = reporter_class.new(configuration)
          reporter.register_listener(formatter, *notifications)
          reporter
        end
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

      # Return options
      #
      # @return [RSpec::Core::ConfigurationOptions]
      #
      # @api private
      #
      def options
        options = RSpec::Core::ConfigurationOptions.new(%w[--fail-fast spec])
        options.parse_options if rspec2?
        options
      end
      memoize :options, freezer: :noop

    end # Strategy
  end # Rspec
end # Mutant
