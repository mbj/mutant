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

      # Return report for test
      #
      # @param [Rspec::Test] test
      #
      # @return [Test::Report]
      #
      # @api private
      #
      def run(test)
        output = StringIO.new
        success = false
        reporter = new_reporter(output)
        reporter.report(1) do
          success = example_group_index.fetch(test.expression.syntax).run(reporter)
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
        example_group_index.keys.each_with_object([]) do |full_description, aggregate|
          expression = Expression.parse(full_description) or next

          aggregate << Test.new(self, expression)
        end
      end
      memoize :all_tests

    private

      # Return all example groups
      #
      # @return [Hash<String, RSpec::Core::ExampleGroup]
      #
      # @api private
      #
      def example_group_index
        Hash[RSpec.world.example_groups.flat_map(&:descendants).map do |example_group|
          [full_description(example_group), example_group]
        end]
      end
      memoize :example_group_index

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

        # rspec3 does require that one via a very indirect autoload setup
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

      # Test for rspec2
      #
      # @return [Boolean]
      #
      # @api private
      #
      def rspec2?
        RSpec::Core::Version::STRING.start_with?(RSPEC_2_VERSION_PREFIX)
      end

      # Return full description for example group
      #
      # @param [RSpec::Core::ExampleGroup] example_group
      #
      # @return [String]
      #
      # @api private
      #
      def full_description(example_group)
        metadata = example_group.metadata
        if rspec2?
          metadata.fetch(:example_group).fetch(:full_description)
        else
          metadata.fetch(:full_description)
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
