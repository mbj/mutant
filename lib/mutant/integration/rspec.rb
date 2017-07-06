require 'rspec/core'

module Mutant
  class Integration
    # Rspec integration
    #
    # This looks so complicated, because rspec:
    #
    # * Keeps its state global in RSpec.world and lots of other places
    # * There is no API to "just run a subset of examples", the examples
    #   need to be selected in-place via mutating the `RSpec.filtered_examples`
    #   data structure
    # * Does not maintain a unique identification for an example,
    #   aside the instances of `RSpec::Core::Example` objects itself.
    #   For that reason identifying examples by:
    #   * full description
    #   * location
    #   Is NOT enough. It would not be unique. So we add an "example index"
    #   for unique reference.
    #
    # :reek:TooManyConstants
    class Rspec < self

      ALL_EXPRESSION       = Expression::Namespace::Recursive.new(scope_name: nil)
      EXPRESSION_CANDIDATE = /\A([^ ]+)(?: )?/.freeze
      LOCATION_DELIMITER   = ':'.freeze
      EXIT_SUCCESS         = 0
      CLI_OPTIONS          = IceNine.deep_freeze(%w[spec --fail-fast])
      TEST_ID_FORMAT       = 'rspec:%<index>d:%<location>s/%<description>s'.freeze

      private_constant(*constants(false))

      # Initialize rspec integration
      #
      # @return [undefined]
      def initialize(*)
        super
        @output = StringIO.new
        @runner = RSpec::Core::Runner.new(RSpec::Core::ConfigurationOptions.new(CLI_OPTIONS))
        @world  = RSpec.world
      end

      # Setup rspec integration
      #
      # @return [self]
      def setup
        @runner.setup($stderr, @output)
        self
      end
      memoize :setup

      # Run a collection of tests
      #
      # @param [Enumerable<Mutant::Test>] tests
      #
      # @return [Result::Test]
      #
      # rubocop:disable MethodLength
      def call(tests)
        examples = tests.map(&all_tests_index.method(:fetch))
        filter_examples(&examples.method(:include?))
        start = Time.now
        passed = @runner.run_specs(@world.ordered_example_groups).equal?(EXIT_SUCCESS)
        @output.rewind
        Result::Test.new(
          output:  @output.read,
          passed:  passed,
          runtime: Time.now - start,
          tests:   tests
        )
      end

      # Available tests
      #
      # @return [Enumerable<Test>]
      def all_tests
        all_tests_index.keys
      end
      memoize :all_tests

    private

      # Index of available tests
      #
      # @return [Hash<Test, RSpec::Core::Example]
      def all_tests_index
        all_examples.each_with_index.each_with_object({}) do |(example, example_index), index|
          index[parse_example(example, example_index)] = example
        end
      end
      memoize :all_tests_index

      # Parse example into test
      #
      # @param [RSpec::Core::Example] example
      # @param [Integer] index
      #
      # @return [Test]
      def parse_example(example, index)
        metadata = example.metadata

        id = TEST_ID_FORMAT % {
          index:       index,
          location:    metadata.fetch(:location),
          description: metadata.fetch(:full_description)
        }

        Test.new(
          expression: parse_expression(metadata),
          id:         id
        )
      end

      # Parse metadata into expression
      #
      # @param [RSpec::Core::Example::MetaData] metadata
      #
      # @return [Expression]
      def parse_expression(metadata)
        if metadata.key?(:mutant_expression)
          expression_parser.(metadata.fetch(:mutant_expression))
        else
          match = EXPRESSION_CANDIDATE.match(metadata.fetch(:full_description))
          expression_parser.try_parse(match.captures.first) || ALL_EXPRESSION
        end
      end

      # Available rspec examples
      #
      # @return [Array<String, RSpec::Core::Example]
      def all_examples
        @world.example_groups.flat_map(&:descendants).flat_map(&:examples).select do |example|
          example.metadata.fetch(:mutant, true)
        end
      end

      # Filter examples
      #
      # @param [#call] predicate
      #
      # @return [undefined]
      def filter_examples(&predicate)
        @world.filtered_examples.each_value do |examples|
          examples.keep_if(&predicate)
        end
      end

    end # Rspec
  end # Integration
end # Mutant
