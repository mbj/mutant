# frozen_string_literal: true

module Mutant
  # Commandline parser / runner
  #
  # rubocop:disable Metrics/ClassLength
  class CLI
    include Concord.new(:world, :config)

    private_class_method :new

    OPTIONS =
      %i[
        add_environment_options
        add_mutation_options
        add_filter_options
        add_debug_options
      ].freeze

    private_constant(*constants(false))

    # Run cli with arguments
    #
    # @param [World] world
    #   the outside world
    #
    # @param [Config] default_config
    #   the default config
    #
    # @param [Array<String>]
    #   the user provided arguments
    #
    # @return [Boolean]
    #
    # rubocop:disable Style/Semicolon
    #
    # ignore :reek:LongParameterList
    def self.run(world, default_config, arguments)
      License
        .apply(world)
        .bind { Config.load_config_file(world, default_config) }
        .bind { |file_config| apply(world, file_config, arguments) }
        .bind { |cli_config| Bootstrap.apply(world, cli_config) }
        .bind(&Runner.method(:apply))
        .from_right { |error| world.stderr.puts(error); return false }
        .success?
    end
    # rubocop:enable Style/Semicolon

    # Parse arguments into config
    #
    # @param [World] world
    # @param [Config] config
    # @param [Array<String>] arguments
    #
    # @return [Either<OptionParser::ParseError, Config>]
    #
    # ignore :reek:LongParameterList
    def self.apply(world, config, arguments)
      Either
        .wrap_error(OptionParser::ParseError) { new(world, config).parse(arguments) }
        .lmap(&:message)
    end

    # Local opt out of option parser defaults
    class OptionParser < ::OptionParser
      # Kill defaults added by option parser that
      # inference with ours under mutation testing.
      define_method(:add_officious) {}
    end # OptionParser

    # Parse the command-line options
    #
    # @param [Array<String>] arguments
    #   Command-line options and arguments to be parsed.
    #
    # @return [Config]
    def parse(arguments)
      opts = OptionParser.new do |builder|
        builder.banner = 'usage: mutant [options] MATCH_EXPRESSION ...'
        OPTIONS.each do |name|
          __send__(name, builder)
        end
      end

      parse_match_expressions(opts.parse!(arguments.dup))

      config
    end

  private

    def parse_match_expressions(expressions)
      expressions.each do |expression|
        add_matcher(:match_expressions, config.expression_parser.apply(expression).from_right)
      end
    end

    # rubocop:disable Metrics/MethodLength
    def add_environment_options(opts)
      opts.separator('Environment:')
      opts.on('--zombie', 'Run mutant zombified') do
        with(zombie: true)
      end
      opts.on('-I', '--include DIRECTORY', 'Add DIRECTORY to $LOAD_PATH') do |directory|
        add(:includes, directory)
      end
      opts.on('-r', '--require NAME', 'Require file with NAME') do |name|
        add(:requires, name)
      end
      opts.on('-j', '--jobs NUMBER', 'Number of kill jobs. Defaults to number of processors.') do |number|
        with(jobs: Integer(number))
      end
    end
    # rubocop:enable Metrics/MethodLength

    def add_mutation_options(opts)
      opts.separator(nil)
      opts.separator('Options:')

      opts.on('--use INTEGRATION', 'Use INTEGRATION to kill mutations') do |name|
        with(integration: name)
      end
    end

    # rubocop:disable Metrics/MethodLength
    def add_filter_options(opts)
      opts.on('--ignore-subject EXPRESSION', 'Ignore subjects that match EXPRESSION as prefix') do |pattern|
        add_matcher(:ignore_expressions, config.expression_parser.apply(pattern).from_right)
      end
      opts.on('--start-subject EXPRESSION', 'Start mutation testing at a specific subject') do |pattern|
        add_matcher(:start_expressions, config.expression_parser.apply(pattern).from_right)
      end
      opts.on('--since REVISION', 'Only select subjects touched since REVISION') do |revision|
        add_matcher(
          :subject_filters,
          Repository::SubjectFilter.new(
            Repository::Diff.new(to: revision, world: world)
          )
        )
      end
    end
    # rubocop:enable Metrics/MethodLength

    # rubocop:disable Metrics/MethodLength
    def add_debug_options(opts)
      opts.on('--fail-fast', 'Fail fast') do
        with(fail_fast: true)
      end
      opts.on('--version', 'Print mutants version') do
        world.stdout.puts("mutant-#{VERSION}")
        world.kernel.exit
      end
      opts.on_tail('-h', '--help', 'Show this message') do
        world.stdout.puts(opts.to_s)
        world.kernel.exit
      end
    end
    # rubocop:enable Metrics/MethodLength

    def with(attributes)
      @config = config.with(attributes)
    end

    def add(attribute, value)
      with(attribute => config.public_send(attribute) + [value])
    end

    def add_matcher(attribute, value)
      with(matcher: config.matcher.add(attribute, value))
    end
  end # CLI
  # rubocop:enable Metrics/ClassLength
end # Mutant
