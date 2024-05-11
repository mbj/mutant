# frozen_string_literal: true

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
    # rubocop:disable Metrics/ClassLength
    class Rspec < self
      ALL_EXPRESSION       = Expression::Namespace::Recursive.new(scope_name: nil)
      EXPRESSION_CANDIDATE = /\A([^ ]+)(?: )?/
      EXIT_SUCCESS         = 0
      DEFAULT_CLI_OPTIONS  = %w[--fail-fast spec].freeze
      TEST_ID_FORMAT       = 'rspec:%<index>d:%<location>s/%<description>s'

      private_constant(*constants(false))

      def freeze
        super() if @setup_elapsed
        self
      end

      # Initialize rspec integration
      #
      # @return [undefined]
      def initialize(*)
        super
        @runner      = RSpec::Core::Runner.new(RSpec::Core::ConfigurationOptions.new(effective_arguments))
        @rspec_world = RSpec.world
      end

      # Setup rspec integration
      #
      # @return [self]
      def setup
        @setup_elapsed = timer.elapsed do
          @runner.setup(world.stderr, world.stdout)
          fail 'RSpec setup failure' if rspec_setup_failure?
          example_group_map
        end
        @runner.configuration.force(color_mode: :on)
        @runner.configuration.reporter
        reset_examples
        freeze
      end
      memoize :setup

      # Run a collection of tests
      #
      # @param [Enumerable<Mutant::Test>] tests
      #
      # @return [Result::Test]
      #
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def call(tests)
        reset_examples
        setup_examples(tests.map(&all_tests_index))
        @runner.configuration.start_time = world.time.now - @setup_elapsed
        start = timer.now
        passed = @runner.run_specs(@rspec_world.ordered_example_groups).equal?(EXIT_SUCCESS)
        @runner.configuration.reset_reporter

        Result::Test.new(
          job_index: nil,
          output:    '',
          passed:    passed,
          runtime:   timer.now - start
        )
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      # All tests
      #
      # @return [Enumerable<Test>]
      def all_tests
        all_tests_index.keys
      end
      memoize :all_tests

      # Available tests
      #
      # @return [Enumerable<Test>]
      def available_tests
        all_tests_index.select { |_test, example| example.metadata.fetch(:mutant, true) }.keys
      end
      memoize :available_tests

    private

      def rspec_setup_failure?
        @rspec_world.wants_to_quit || rspec_is_quitting?
      end

      def rspec_is_quitting?
        @rspec_world.respond_to?(:rspec_is_quitting) && @rspec_world.rspec_is_quitting
      end

      def effective_arguments
        arguments.empty? ? DEFAULT_CLI_OPTIONS : arguments
      end

      def reset_examples
        @rspec_world.filtered_examples.each_value(&:clear)
      end

      def setup_examples(examples)
        examples.each do |example|
          @rspec_world.filtered_examples.fetch(example_group_map.fetch(example)) << example
        end
      end

      def all_tests_index
        all_examples.each_with_index.with_object({}) do |(example, example_index), index|
          index[parse_example(example, example_index)] = example
        end
      end
      memoize :all_tests_index

      def parse_example(example, index)
        metadata = example.metadata

        id = TEST_ID_FORMAT % {
          index:       index,
          location:    metadata.fetch(:location),
          description: metadata.fetch(:full_description)
        }

        Test.new(
          expressions: parse_metadata(metadata),
          id:          id
        )
      end

      def example_group_map
        @rspec_world.example_groups.flat_map(&:descendants).each_with_object({}) do |example_group, map|
          example_group.examples.each do |example|
            map[example] = example_group
          end
        end
      end
      memoize :example_group_map

      def parse_metadata(metadata)
        if metadata.key?(:mutant_expression)
          expression = metadata.fetch(:mutant_expression)

          expressions =
            expression.instance_of?(Array) ? expression : [expression]

          expressions.map(&method(:parse_expression))
        else
          match = EXPRESSION_CANDIDATE.match(metadata.fetch(:full_description))
          [parse_expression(match.captures.first) { ALL_EXPRESSION }]
        end
      end

      def parse_expression(input, &default)
        expression_parser.call(input).from_right(&default)
      end

      def all_examples
        @rspec_world.example_groups.flat_map(&:descendants).flat_map(&:examples)
      end
    end # Rspec
    # rubocop:enable Metrics/ClassLength
  end # Integration
end # Mutant
