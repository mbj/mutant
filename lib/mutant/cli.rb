module Mutant

  # Commandline parser
  class CLI
    include Adamantium::Flat, Equalizer.new(:config), Procto.call(:config)

    # Error failed when CLI argv is invalid
    Error = Class.new(RuntimeError)

    EXIT_FAILURE = 1
    EXIT_SUCCESS = 0

    # Run cli with arguments
    #
    # @param [Array<String>] arguments
    #
    # @return [Fixnum]
    #   the exit status
    #
    # @api private
    def self.run(arguments)
      Runner.call(Env::Bootstrap.call(call(arguments))).success? ? EXIT_SUCCESS : EXIT_FAILURE
    rescue Error => exception
      $stderr.puts(exception.message)
      EXIT_FAILURE
    end

    # Initialize objecct
    #
    # @param [Array<String>]
    #
    # @return [undefined]
    #
    # @api private
    def initialize(arguments)
      @config = Config::DEFAULT

      parse(arguments)
    end

    # Config parsed from CLI
    #
    # @return [Config]
    #
    # @api private
    attr_reader :config

  private

    # Parse the command-line options
    #
    # @param [Array<String>] arguments
    #   Command-line options and arguments to be parsed.
    #
    # @fail [Error]
    #   An error occurred while parsing the options.
    #
    # @return [undefined]
    #
    # @api private
    def parse(arguments)
      opts = OptionParser.new do |builder|
        builder.banner = 'usage: mutant [options] MATCH_EXPRESSION ...'
        %w[add_environment_options add_mutation_options add_filter_options add_debug_options].each do |name|
          __send__(name, builder)
        end
      end

      parse_match_expressions(opts.parse!(arguments))
    rescue OptionParser::ParseError => error
      raise(Error, error)
    end

    # Parse matchers
    #
    # @param [Array<String>] expressions
    #
    # @return [undefined]
    #
    # @api private
    def parse_match_expressions(expressions)
      fail Error, 'No expressions given' if expressions.empty?

      expressions.each do |expression|
        add_matcher(:match_expressions, expression)
      end
    end

    # Add environmental options
    #
    # @param [Object] opts
    #
    # @return [undefined]
    #
    # rubocop:disable MethodLength
    #
    # @api private
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
    #
    # @api private
    def setup_integration(name)
      Integration.setup(name)
      with(integration: name)
    rescue LoadError
      raise Error, "Could not load integration #{name.inspect} (install the gem mutant-#{name} if exists)"
    end

    # Add mutation options
    #
    # @param [OptionParser] opts
    #
    # @return [undefined]
    #
    # @api private
    def add_mutation_options(opts)
      opts.separator(nil)
      opts.separator('Options:')

      opts.on(
        '--expected-coverage COVERAGE',
        'Fail unless COVERAGE is not reached exactly, parsed via Rational()'
      ) do |coverage|
        with(expected_coverage: Rational(coverage))
      end
      opts.on('--use INTEGRATION', 'Use INTEGRATION to kill mutations', &method(:setup_integration))
    end

    # Add filter options
    #
    # @param [OptionParser] opts
    #
    # @return [undefined]
    #
    # @api private
    def add_filter_options(opts)
      opts.on('--ignore-subject EXPRESSION', 'Ignore subjects that match EXPRESSION as prefix') do |pattern|
        add_matcher(:ignore_expressions, pattern)
      end
      opts.on('--since REVISION', 'Only select subjects touched since REVISION') do |revision|
        add_matcher(:subject_filters, Repository::SubjectFilter.new(Repository::Diff.from_head(revision)))
      end
    end

    # Add debug options
    #
    # @param [OptionParser] opts
    #
    # @return [undefined]
    #
    # @api private
    def add_debug_options(opts)
      opts.on('--fail-fast', 'Fail fast') do
        with(fail_fast: true)
      end
      opts.on('--version', 'Print mutants version') do
        puts("mutant-#{VERSION}")
        Kernel.exit(EXIT_SUCCESS)
      end
      opts.on('-d', '--debug', 'Enable debugging output') do
        with(debug: true)
      end
      opts.on_tail('-h', '--help', 'Show this message') do
        puts(opts.to_s)
        Kernel.exit(EXIT_SUCCESS)
      end
    end

    # With configuration
    #
    # @param [Hash<Symbol, Object>] attributes
    #
    # @return [undefined]
    #
    # @api private
    def with(attributes)
      @config = @config.with(attributes)
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
    #
    # @api private
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
    #
    # @api private
    def add_matcher(attribute, value)
      with(matcher: config.matcher.add(attribute, value))
    end

  end # CLI
end # Mutant
