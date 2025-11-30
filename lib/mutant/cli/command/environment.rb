# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      # rubocop:disable Metrics/ClassLength
      class Environment < self
        NAME              = 'environment'
        SHORT_DESCRIPTION = 'Environment subcommands'

        OPTIONS =
          %i[
            add_environment_options
            add_runner_options
            add_integration_options
            add_matcher_options
            add_reporter_options
            add_sorbet_options
            add_usage_options
          ].freeze

      private

        def initialize(_attributes)
          super
          @config = Config::DEFAULT.with(
            coverage_criteria: Config::CoverageCriteria::EMPTY
          )
        end

        def bootstrap
          env = Env.empty(world, @config)

          env
            .record(:config) { Config.load(cli_config: @config, world:) }
            .bind { |config| Bootstrap.call(env.with(config:)) }
        end

        def parse_remaining_arguments(arguments)
          Mutant.traverse(@config.expression_parser, arguments)
            .fmap do |expressions|
              matcher(subjects: expressions)
              self
            end
        end

        def set(**attributes)
          @config = @config.with(attributes)
        end

        def matcher(**attributes)
          set(matcher: @config.matcher.with(attributes))
        end

        def add(attribute, value)
          set(attribute => @config.public_send(attribute) + [value])
        end

        def add_matcher(attribute, value)
          set(matcher: @config.matcher.add(attribute, value))
        end

        def effective_options
          instance_of?(Environment) ? EMPTY_ARRAY : super
        end

        # rubocop:disable Metrics/MethodLength
        def add_environment_options(parser)
          parser.separator('Environment:')
          parser.on('-I', '--include DIRECTORY', 'Add DIRECTORY to $LOAD_PATH') do |directory|
            add(:includes, directory)
          end
          parser.on('-r', '--require NAME', 'Require file with NAME') do |name|
            add(:requires, name)
          end
          parser.on('--env KEY=VALUE', 'Set environment variable') do |value|
            match = ENV_VARIABLE_KEY_VALUE_REGEXP.match(value) || fail("Invalid env variable: #{value.inspect}")
            set(
              environment_variables: @config.environment_variables.merge(match[:key] => match[:value])
            )
          end
        end
        # rubocop:enable Metrics/MethodLength

        def add_integration_options(parser)
          parser.separator('Integration:')

          parser.on('--use INTEGRATION', 'deprecated alias for --integration', &method(:assign_integration_name))
          parser.on('--integration NAME', 'Use test integration with NAME', &method(:assign_integration_name))

          parser.on(
            '--integration-argument ARGUMENT', 'Pass ARGUMENT to integration',
            &method(:add_integration_argument)
          )
        end

        def add_integration_argument(value)
          config = @config.integration
          set(integration: config.with(arguments: config.arguments + [value]))
        end

        def assign_integration_name(name)
          set(integration: @config.integration.with(name:))
        end

        def add_matcher_options(parser)
          parser.separator('Matcher:')

          parser.on('--ignore-subject EXPRESSION', 'Ignore subjects that match EXPRESSION as prefix') do |pattern|
            add_matcher(:ignore, @config.expression_parser.call(pattern).from_right)
          end
          parser.on('--start-subject EXPRESSION', 'Start mutation testing at a specific subject') do |pattern|
            add_matcher(:start_expressions, @config.expression_parser.call(pattern).from_right)
          end
          parser.on('--since REVISION', 'Only select subjects touched since REVISION') do |revision|
            add_matcher(:diffs, Repository::Diff.new(to: revision, world:))
          end
        end

        def add_runner_options(parser)
          parser.separator('Runner:')

          parser.on('--fail-fast', 'Fail fast') do
            set(fail_fast: true)
          end
          parser.on('-j', '--jobs NUMBER', 'Number of kill jobs. Defaults to number of processors.') do |number|
            set(jobs: Integer(number))
          end
          parser.on('-t', '--mutation-timeout NUMBER', 'Per mutation analysis timeout') do |number|
            set(mutation: @config.mutation.with(timeout: Float(number)))
          end
        end

        def add_reporter_options(parser)
          parser.separator('Reporting:')

          parser.on('--print-warnings', 'Print warnings') do
            set(reporter: @config.reporter.with(print_warnings: true))
          end
        end

        def add_sorbet_options(parser)
          parser.separator('Sorbet:')

          parser.on('--use-sorbet', 'Enable Sorbet type checking (mutations with type errors will be skipped)') do
            set(sorbet: @config.sorbet.with(enabled: true))
          end

          parser.on('--no-sorbet', 'Disable Sorbet type checking') do
            set(sorbet: @config.sorbet.with(enabled: false))
          end

          parser.on('--sorbet-timeout SECONDS', 'Timeout for type checking a mutation (float)') do |timeout|
            set(sorbet: @config.sorbet.with(timeout: Float(timeout)))
          end

          parser.on('--sorbet-binary PATH', 'Path to Sorbet binary') do |path|
            set(sorbet: @config.sorbet.with(binary: path))
          end
        end

        def add_usage_options(parser)
          parser.separator('Usage:')

          parser.accept(Usage, Usage::CLI_REGEXP) do |value|
            Usage.parse(value).from_right
          end

          parser.on(
            '--usage USAGE_TYPE',
            Usage,
            'License usage: opensource|commercial'
          ) { |usage| set(usage:) }
        end
      end # Run
      # rubocop:enable Metrics/ClassLength
    end # Command
  end # CLI
end # Mutant
