# frozen_string_literal: true

module Mutant
  module CLI
    class Command
      class Environment < self
        NAME              = 'environment'
        SHORT_DESCRIPTION = 'Environment subcommands'

        OPTIONS =
          %i[
            add_environment_options
            add_runner_options
            add_integration_options
            add_matcher_options
          ].freeze

      private

        def initialize(attributes)
          super(attributes)
          @config = Config::DEFAULT
        end

        def bootstrap
          Config.load_config_file(world)
            .fmap(&method(:expand))
            .bind { Bootstrap.call(world, @config) }
        end

        def expand(file_config)
          if @config.matcher.subjects.any?
            file_config = file_config.with(
              matcher: file_config.matcher.with(subjects: [])
            )
          end

          @config = Config.env.merge(file_config).merge(@config).expand_defaults
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

        def add_environment_options(parser)
          parser.separator('Environment:')
          parser.on('--zombie', 'Run mutant zombified') do
            set(zombie: true)
          end
          parser.on('-I', '--include DIRECTORY', 'Add DIRECTORY to $LOAD_PATH') do |directory|
            add(:includes, directory)
          end
          parser.on('-r', '--require NAME', 'Require file with NAME') do |name|
            add(:requires, name)
          end
        end

        def add_integration_options(parser)
          parser.separator('Integration:')

          parser.on('--use INTEGRATION', 'Use INTEGRATION to kill mutations') do |name|
            set(integration: name)
          end
        end

        # rubocop:disable Metrics/MethodLength
        def add_matcher_options(parser)
          parser.separator('Matcher:')

          parser.on('--ignore-subject EXPRESSION', 'Ignore subjects that match EXPRESSION as prefix') do |pattern|
            add_matcher(:ignore, @config.expression_parser.call(pattern).from_right)
          end
          parser.on('--start-subject EXPRESSION', 'Start mutation testing at a specific subject') do |pattern|
            add_matcher(:start_expressions, @config.expression_parser.call(pattern).from_right)
          end
          parser.on('--since REVISION', 'Only select subjects touched since REVISION') do |revision|
            add_matcher(
              :subject_filters,
              Repository::SubjectFilter.new(
                Repository::Diff.new(to: revision, world: world)
              )
            )
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
            set(mutation_timeout: Float(number))
          end
        end
      end # Run
    end # Command
  end # CLI
end # Mutant
