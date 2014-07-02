# encoding: UTF-8
require 'rspec/core'

require 'rspec/core/formatters/base_text_formatter'

module Mutant
  class Integration
    # Shared parts of rspec2/3 integration
    class Rspec < self
      include AbstractType

      # Setup rspec integration
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
          expression = Expression.try_parse(full_description) or next

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
        RSpec::Core::ConfigurationOptions.new(%w[--fail-fast spec])
      end
      memoize :options, freezer: :noop

    end # Rspec
  end # Integration
end # Mutant

RSPEC_2_VERSION_PREFIX = '2.'.freeze

if RSpec::Core::Version::STRING.start_with?(RSPEC_2_VERSION_PREFIX)
  require 'mutant/integration/rspec2'
else
  require 'mutant/integration/rspec3'
end
