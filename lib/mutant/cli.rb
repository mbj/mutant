require 'optparse'

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
    #
    def self.run(arguments)
      Env.call(call(arguments)).success? ? EXIT_SUCCESS : EXIT_FAILURE
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
    #
    def initialize(arguments)
      @config = Config::DEFAULT

      parse(arguments)
    end

    # Return config
    #
    # @return [Config]
    #
    # @api private
    #
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
    #
    def parse(arguments)
      opts = OptionParser.new do |builder|
        builder.banner = 'usage: mutant [options] MATCH_EXPRESSION ...'
        %w[add_environment_options add_mutation_options add_filter_options add_debug_options].each do |name|
          send(name, builder)
        end
      end

      parse_match_expressions(opts.parse!(arguments))
    rescue OptionParser::ParseError => error
      fail(Error, error.message, error.backtrace)
    end

    # Parse matchers
    #
    # @param [Array<String>] patterns
    #
    # @return [undefined]
    #
    # @api private
    #
    def parse_match_expressions(expressions)
      fail Error, 'No expressions given' if expressions.empty?

      expressions.map(&Expression.method(:parse)).each do |expression|
        add_matcher(:match_expressions, expression)
      end
    end

    # Add environmental options
    #
    # @param [Object] opts
    #
    # @return [undefined]
    #
    # @api private
    #
    def add_environment_options(opts)
      opts.separator('Environment:')
      opts.on('--zombie', 'Run mutant zombified') do
        update(zombie: true)
      end
      opts.on('-I', '--include DIRECTORY', 'Add DIRECTORY to $LOAD_PATH') do |directory|
        add(:includes, directory)
      end
      opts.on('-r', '--require NAME', 'Require file with NAME') do |name|
        add(:requires, name)
      end
      opts.on('-j', '--jobs NUMBER', 'Number of kill processes. Defaults to number of processors.') do |number|
        update(processes: Integer(number))
      end
    end

    # Use integration
    #
    # @param [String] name
    #
    # @return [undefined]
    #
    # @api private
    #
    def setup_integration(name)
      require "mutant/integration/#{name}"
      update(integration: Integration.lookup(name))
    end

    # Add options
    #
    # @param [OptionParser] opts
    #
    # @return [undefined]
    #
    # @api private
    #
    def add_mutation_options(opts)
      opts.separator(EMPTY_STRING)
      opts.separator('Options:')

      opts.on('--score COVERAGE', 'Fail unless COVERAGE is not reached exactly') do |coverage|
        update(expected_coverage: Float(coverage))
      end.on('--use STRATEGY', 'Use STRATEGY for killing mutations', &method(:setup_integration))
    end

    # Add filter options
    #
    # @param [OptionParser] opts
    #
    # @return [undefined]
    #
    # @api private
    #
    def add_filter_options(opts)
      opts.on('--ignore-subject PATTERN', 'Ignore subjects that match PATTERN') do |pattern|
        add_matcher(:subject_ignores, Expression.parse(pattern))
      end
      opts.on('--code CODE', 'Scope execution to subjects with CODE') do |code|
        add_matcher(:subject_selects, [:code, code])
      end
    end

    # Add debug options
    #
    # @param [OptionParser] opts
    #
    # @return [undefined]
    #
    # @api private
    #
    def add_debug_options(opts)
      opts.on('--fail-fast', 'Fail fast') do
        update(fail_fast: true)
      end.on('--version', 'Print mutants version') do
        puts("mutant-#{Mutant::VERSION}")
        Kernel.exit(EXIT_SUCCESS)
      end.on('-d', '--debug', 'Enable debugging output') do
        update(debug: true)
      end.on_tail('-h', '--help', 'Show this message') do
        puts(opts.to_s)
        Kernel.exit(EXIT_SUCCESS)
      end
    end

    # Update configuration
    #
    # @param [Hash<Symbol, Object>] attributes
    #
    # @return [undefined]
    #
    # @api private
    #
    def update(attributes)
      @config = @config.update(attributes)
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
    #
    def add(attribute, value)
      update(attribute => config.public_send(attribute).dup << value)
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
    #
    def add_matcher(attribute, value)
      update(matcher_config: config.matcher_config.add(attribute, value))
    end

  end # CLI
end # Mutant
