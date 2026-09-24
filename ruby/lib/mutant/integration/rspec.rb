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
    class Rspec < self
      ALL_EXPRESSION       = Expression::Namespace::Recursive.new(scope_name: nil)
      EXPRESSION_CANDIDATE = /\A([^ ]+)(?: )?/
      EXIT_SUCCESS         = 0
      DEFAULT_CLI_OPTIONS  = %w[--fail-fast spec].freeze
      TEST_ID_FORMAT       = 'rspec:%<index>d:%<location>s/%<description>s'

      private_constant(*constants(false))

      # Rspec ordering strategy driven by the order mutant selected the tests in
      #
      # Rspec runs one group at a time, so a group is ranked by the best test it
      # holds, and the ranking survives as group order plus example order within
      # a group. Anything rspec asks about that was not selected sorts last.
      class Ordering
        UNRANKED = Float::INFINITY

        private_constant(*constants(false))

        def initialize = @rank = {}

        # Rank examples, best first
        #
        # @param [Enumerable<RSpec::Core::Example>] examples
        #
        # @return [self]
        def call(examples)
          @rank.clear

          examples.each_with_index do |example, rank|
            @rank[example] = rank

            example.example_group.parent_groups.each do |group|
              @rank[group] = rank if @rank.fetch(group, UNRANKED) > rank
            end
          end

          self
        end

        # Order the groups or the examples rspec is about to run
        #
        # Rspec's own id breaks a tie, so the order does not depend on the order
        # rspec happened to hand the list over in.
        #
        # @param [Array<Object>] list
        #
        # @return [Array<Object>]
        def order(list)
          list.sort_by { |item| [@rank.fetch(item, UNRANKED), item.id] }
        end
      end # Ordering

      def freeze = tap { super if @setup_elapsed }

      # Initialize rspec integration
      #
      # @return [undefined]
      def initialize(*)
        super
        @ordering    = Ordering.new
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

      # Run a collection of tests, likeliest killer first
      #
      # @param [Enumerable<Mutant::Test>] tests
      #
      # @return [Result::Test]
      #
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def call(tests)
        examples = tests.map(&all_tests_index)

        install_ordering
        reset_examples
        @ordering.call(examples)
        setup_examples(examples)
        @runner.configuration.start_time = world.time.now - @setup_elapsed
        start = timer.now
        passed = @runner.run_specs(@rspec_world.ordered_example_groups).equal?(EXIT_SUCCESS)
        @runner.configuration.reset_reporter

        Result::Test.new(
          job_index: nil,
          output:    LogCapture::String.new(content: ''),
          passed:,
          runtime:   timer.now - start
        )
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      # All tests
      #
      # @return [Enumerable<Test>]
      def all_tests = all_tests_index.keys
      memoize :all_tests

      # Available tests
      #
      # @return [Enumerable<Test>]
      def available_tests = all_tests_index.select { |_test, example| example.metadata.fetch(:mutant, true) }.keys
      memoize :available_tests

    private

      # Rspec picks its own order for groups and for the examples inside them,
      # which would throw away the selector's ranking. Its ordering registry is
      # the seam for that, but the public `register_ordering(:global)` is a noop
      # once `--order` was forced from the command line or `.rspec`, which most
      # suites do. Registering with the registry is the only way in.
      #
      # Registered per run rather than at setup: the strategy is the same object
      # every time, and a run is the moment its ranking is known.
      def install_ordering
        @runner.configuration.ordering_registry.register(:global, @ordering)
      end

      def rspec_setup_failure?
        @rspec_world.wants_to_quit || rspec_is_quitting?
      end

      def rspec_is_quitting?
        @rspec_world.respond_to?(:rspec_is_quitting) && @rspec_world.rspec_is_quitting
      end

      def effective_arguments = arguments.empty? ? DEFAULT_CLI_OPTIONS : arguments

      def reset_examples = @rspec_world.filtered_examples.each_value(&:clear)

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

        Test.new(
          expressions: parse_metadata(metadata),
          id:          test_id(metadata, index),
          location:    metadata.fetch(:location)
        )
      end

      def test_id(metadata, index)
        TEST_ID_FORMAT % {
          index:,
          location:    metadata.fetch(:location),
          description: metadata.fetch(:full_description)
        }
      end

      def example_group_map
        @rspec_world.example_groups.flat_map(&:descendants).each_with_object({}) do |example_group, map|
          example_group.examples.each do |example|
            map[example] = example_group
          end
        end
      end
      memoize :example_group_map

      # mutant:disable -- 3.3 specific mutation on match.captures -> match
      def parse_metadata(metadata)
        if metadata.key?(:mutant_expression)
          expression = metadata.fetch(:mutant_expression)

          expressions =
            expression.instance_of?(Array) ? expression : [expression]

          expressions.map(&method(:parse_expression))
        else
          match = EXPRESSION_CANDIDATE.match(metadata.fetch(:full_description)) or return [ALL_EXPRESSION]
          [parse_expression(Util.one(match.captures)) { ALL_EXPRESSION }]
        end
      end

      def parse_expression(input, &)
        expression_parser.call(input).from_right(&)
      end

      def all_examples = @rspec_world.example_groups.flat_map(&:descendants).flat_map(&:examples)
    end # Rspec
  end # Integration
end # Mutant
