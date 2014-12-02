require 'rspec/core'
require 'rspec/core/formatters/base_text_formatter'

module Mutant
  class Integration
    # Shared parts of rspec2/3 integration
    class Rspec < self

      ALL                  = Mutant::Expression.parse('*')
      EXPRESSION_DELIMITER = ' '.freeze
      LOCATION_DELIMITER   = ':'.freeze
      EXIT_SUCCESS         = 0
      CLI_OPTIONS          = IceNine.deep_freeze(%w[spec --fail-fast])

      register 'rspec'

      # Initialize rspec integration
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize
        @output = StringIO.new
        @runner = RSpec::Core::Runner.new(RSpec::Core::ConfigurationOptions.new(CLI_OPTIONS))
        @world  = RSpec.world
      end

      # Setup rspec integration
      #
      # @return [self]
      #
      # @api private
      #
      def setup
        @runner.setup($stderr, @output)
        self
      end
      memoize :setup

      # Return report for test
      #
      # @param [Enumerable<Mutant::Test>] tests
      #
      # @return [Test::Result]
      #
      # @api private
      #
      # rubocop:disable MethodLength
      #
      def call(tests)
        examples = tests.map(&all_tests_index.method(:fetch)).to_set
        filter_examples(&examples.method(:include?))
        start = Time.now
        passed = @runner.run_specs(RSpec.world.ordered_example_groups).equal?(EXIT_SUCCESS)
        @output.rewind
        Result::Test.new(
          tests:    nil,
          output:   @output.read,
          runtime:  Time.now - start,
          passed:   passed
        )
      end

      # Return all available tests
      #
      # @return [Enumerable<Test>]
      #
      # @api private
      #
      def all_tests
        all_tests_index.keys
      end
      memoize :all_tests

    private

      # Return all tests index
      #
      # @return [Hash<Test, RSpec::Core::Example]
      #
      # @api private
      #
      def all_tests_index
        all_examples.each_with_object({}) do |example, index|
          index[parse_example(example)] = example
        end
      end
      memoize :all_tests_index

      # Parse example into test
      #
      # @param [RSpec::Core::Example]
      #
      # @return [Test]
      #
      # @api private
      #
      def parse_example(example)
        metadata = example.metadata
        location = metadata.fetch(:location)
        full_description = metadata.fetch(:full_description)
        expression = Expression.try_parse(full_description.split(EXPRESSION_DELIMITER, 2).first) || ALL

        Test.new(
          id:         "rspec:#{location} / #{full_description}",
          expression: expression
        )
      end

      # Return all examples
      #
      # @return [Array<String, RSpec::Core::Example]
      #
      # @api private
      #
      def all_examples
        @world.example_groups.flat_map(&:descendants).flat_map(&:examples)
      end

      # Filter examples
      #
      # @param [#call] predicate
      #
      # @return [undefined]
      #
      # @api private
      #
      def filter_examples(&predicate)
        @world.filtered_examples.each_value do |examples|
          examples.keep_if(&predicate)
        end
      end

    end # Rspec
  end # Integration
end # Mutant
