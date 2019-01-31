# frozen_string_literal: true

module Mutant
  # Commandline parser / runner
  #
  # rubocop:disable Metrics/ClassLength
  class CLI
    include Concord.new(:config)

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
    # @param [Config] config
    #   the default config
    #
    # @param [Array<String>]
    #   the user provided arguments
    #
    # @return [Boolean]
    #
    # rubocop:disable Style/Semicolon
    def self.run(config, arguments)
      apply(config, arguments)
        .fmap(&Env::Bootstrap.method(:call))
        .fmap(&Runner.method(:call))
        .from_right { |error| config.stderr.puts(error); return false }
        .success?
    end
    # rubocop:enable Style/Semicolon

    # Parse arguments into config
    #
    # @param [Config] config
    # @param [Array<String>] arguments
    #
    # @return [Either<OptionParser::ParseError, Config>]
    def self.apply(config, arguments)
      Either
        .wrap_error(OptionParser::ParseError) { new(config).parse(arguments) }
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

      parse_match_expressions(opts.parse!(arguments))

      config
    end

  private

    # Parse matchers
    #
    # @param [Array<String>] expressions
    #
    # @return [undefined]
    def parse_match_expressions(expressions)
      expressions.each do |expression|
        add_matcher(:match_expressions, config.expression_parser.(expression))
      end
    end

    # Add environmental options
    #
    # @param [Object] opts
    #
    # @return [undefined]
    #
    # rubocop:disable MethodLength
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

    # Use integration
    #
    # @param [String] name
    #
    # @return [undefined]
    def setup_integration(name)
      with(integration: Integration.setup(config.kernel, name))
    rescue LoadError
      raise(
        OptionParser::InvalidArgument,
        "Could not load integration #{name.inspect} (you may want to try installing the gem mutant-#{name})"
      )
    end

    # Add mutation options
    #
    # @param [OptionParser] opts
    #
    # @return [undefined]
    def add_mutation_options(opts)
      opts.separator(nil)
      opts.separator('Options:')

      opts.on('--use INTEGRATION', 'Use INTEGRATION to kill mutations', &method(:setup_integration))
    end

    # Add filter options
    #
    # @param [OptionParser] opts
    #
    # @return [undefined]
    def add_filter_options(opts)
      opts.on('--ignore-subject EXPRESSION', 'Ignore subjects that match EXPRESSION as prefix') do |pattern|
        add_matcher(:ignore_expressions, config.expression_parser.(pattern))
      end
      opts.on('--since REVISION', 'Only select subjects touched since REVISION') do |revision|
        add_matcher(
          :subject_filters,
          Repository::SubjectFilter.new(
            Repository::Diff.new(
              config: config,
              from:   Repository::Diff::HEAD,
              to:     revision
            )
          )
        )
      end
    end

    # Add debug options
    #
    # @param [OptionParser] opts
    #
    # @return [undefined]
    def add_debug_options(opts)
      opts.on('--fail-fast', 'Fail fast') do
        with(fail_fast: true)
      end
      opts.on('--version', 'Print mutants version') do
        config.stdout.puts("mutant-#{VERSION}")
        config.kernel.exit
      end
      opts.on_tail('-h', '--help', 'Show this message') do
        config.stdout.puts(opts.to_s)
        config.kernel.exit
      end
    end

    # With configuration
    #
    # @param [Hash<Symbol, Object>] attributes
    #
    # @return [undefined]
    def with(attributes)
      @config = config.with(attributes)
    end

    # Add configuration
    #
    # @param [Symbol] attribute
    #   the attribute to add to
    #
    # @param [Object] value
    #   the value to add
    #
    # @return [undefined]
    def add(attribute, value)
      with(attribute => config.public_send(attribute) + [value])
    end

    # Add matcher configuration
    #
    # @param [Symbol] attribute
    #   the attribute to add to
    #
    # @param [Object] value
    #   the value to add
    #
    # @return [undefined]
    def add_matcher(attribute, value)
      with(matcher: config.matcher.add(attribute, value))
    end

  end # CLI
end # Mutant
