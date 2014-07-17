# encoding: UTF-8
require 'rspec/core'
require 'rspec/core/formatters/base_text_formatter'

module Mutant
  class Integration
    # Shared parts of rspec2/3 integration
    class Rspec < self
      include AbstractType

      register 'rspec'

      RSPEC_2_VERSION_PREFIX = '2.'.freeze

      # Return integration compatible to currently loaded rspec
      #
      # @return [Integration]
      #
      # @api private
      #
      def self.build
        if RSpec::Core::Version::STRING.start_with?(RSPEC_2_VERSION_PREFIX)
          Rspec2.new
        else
          Rspec3.new
        end
      end

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
      # @return [Test::Result]
      #
      # @api private
      #
      # rubocop:disable MethodLength
      #
      def run(test)
        output = StringIO.new
        failed = false
        start = Time.now
        reporter = new_reporter(output)
        reporter.report(1) do
          example_group_index.fetch(test.expression.syntax).each do |example_group|
            next if example_group.run(reporter)
            failed = true
            break
          end
        end
        output.rewind
        Result::Test.new(
          test:     nil,
          mutation: nil,
          output:   output.read,
          runtime:  Time.now - start,
          passed:   !failed
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
        index = Hash.new { |hash, key| hash[key] = [] }

        RSpec.world.example_groups.flat_map(&:descendants).each do |example_group|
          full_description = full_description(example_group)
          index[full_description] << example_group
        end

        index
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

      # Rspec2 integration
      class Rspec2 < self

        register 'rspec'

      private

        # Return options
        #
        # @return [RSpec::Core::ConfigurationOptions]
        #
        # @api private
        #
        def options
          super.tap(&:parse_options)
        end

        # Return full description of example group
        #
        # @param [RSpec::Core::ExampleGroup] example_group
        #
        # @return [String]
        #
        # @api private
        #
        def full_description(example_group)
          example_group.metadata.fetch(:example_group).fetch(:full_description)
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
          formatter = RSpec::Core::Formatters::BaseTextFormatter.new(output)

          RSpec::Core::Reporter.new(formatter)
        end

      end # Rspec2

      # Rspec 3 integration
      class Rspec3 < self

      private

        # Return full description for example group
        #
        # @param [RSpec::Core::ExampleGroup] example_group
        #
        # @return [String]
        #
        # @api private
        #
        def full_description(example_group)
          example_group.metadata.fetch(:full_description)
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
          formatter = RSpec::Core::Formatters::BaseTextFormatter.new(output)
          notifications = RSpec::Core::Formatters::Loader.allocate.send(:notifications_for, formatter.class)

          RSpec::Core::Reporter.new(configuration).tap do |reporter|
            reporter.register_listener(formatter, *notifications)
          end
        end

      end # Rspec3
    end # Rspec
  end # Integration
end # Mutant
