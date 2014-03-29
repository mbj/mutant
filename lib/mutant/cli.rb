# encoding: utf-8

require 'optparse'

module Mutant

  # Comandline parser
  class CLI
    include Adamantium::Flat, Equalizer.new(:config), NodeHelpers

    # Error raised when CLI argv is invalid
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
      config = new(arguments).config
      runner = Runner::Config.run(config)
      runner.success? ? EXIT_SUCCESS : EXIT_FAILURE
    rescue Error => exception
      $stderr.puts(exception.message)
      EXIT_FAILURE
    end

    # Builder for configuration components
    class Builder
      include NodeHelpers

      # Initalize object
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize
        @matchers          = []
        @subject_ignores   = []
        @subject_selectors = []
      end

      # Add a subject ignore
      #
      # @param [Matcher]
      #
      # @return [self]
      #
      # @api private
      #
      def add_subject_ignore(matcher)
        @subject_ignores << matcher
        self
      end

      # Add a subject selector
      #
      # @param [#call] selector
      #
      # @return [self]
      def add_subject_selector(selector)
        @subject_selectors << selector
        self
      end

      # Add a subject matcher
      #
      # @param [#call] selector
      #
      # @return [self]
      #
      # @api private
      #
      def add_matcher(matcher)
        @matchers << matcher
        self
      end

      def matcher
        if @matchers.empty?
          raise(Error, 'No patterns given')
        end

        matcher = Matcher::Chain.build(@matchers)

        if predicate
          Matcher::Filter.new(matcher, predicate)
        else
          matcher
        end
      end

    private

      # Return subject selector
      #
      # @return [#call]
      #   if selector is present
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def subject_selector
        if @subject_selectors.any?
          Morpher::Evaluator::Predicate::Boolean::Or.new(@subject_selectors)
        end
      end

      # Return predicate
      #
      # @return [#call]
      #   if filter is needed
      #
      # @return [nil]
      #   othrwise
      #
      # @api private
      #
      def predicate
        if subject_selector && subject_rejector
          Morpher::Evaluator::Predicate::Boolean::And.new([
            subject_selector,
            Morpher::Evaluator::Predicate::Negation.new(subject_rejector)
          ])
        elsif subject_selector
          subject_selector
        elsif subject_rejector
          Morpher::Evaluator::Predicate::Negation.new(subject_rejector)
        else
          nil
        end
      end

      # Return subject rejector
      #
      # @return [#call]
      #
      # @api private
      #
      def subject_rejector
        rejectors = @subject_ignores.flat_map(&:to_a).map do |subject|
          Morpher.compile(s(:eql, s(:attribute, :identification), s(:static, subject.identification)))
        end

        if rejectors.any?
          Morpher::Evaluator::Predicate::Boolean::Or.new(rejectors)
        end
      end
    end

    # Initialize objecct
    #
    # @param [Array<String>]
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(arguments = [])
      @builder = Builder.new
      @debug = @fail_fast = @zombie = false
      @expected_coverage = 100.0
      @strategy = Strategy::Null.new
      @cache = Mutant::Cache.new
      parse(arguments)
      config # trigger lazyness now
    end

    # Return config
    #
    # @return [Config]
    #
    # @api private
    #
    def config
      Config.new(
        cache:             @cache,
        zombie:            @zombie,
        debug:             @debug,
        matcher:           @builder.matcher,
        strategy:          @strategy,
        fail_fast:         @fail_fast,
        reporter:          Reporter::CLI.new($stdout),
        expected_coverage: @expected_coverage
      )
    end
    memoize :config

  private

    # Parse the command-line options
    #
    # @param [Array<String>] arguments
    #   Command-line options and arguments to be parsed.
    #
    # @raise [Error]
    #   An error occurred while parsing the options.
    #
    # @return [undefined]
    #
    # @api private
    #
    def parse(arguments)
      opts = OptionParser.new do |builder|
        builder.banner = 'usage: mutant STRATEGY [options] PATTERN ...'
        builder.separator('')
        add_environmental_options(builder)
        add_mutation_options(builder)
        add_filter_options(builder)
        add_debug_options(builder)
      end

      patterns =
        begin
          opts.parse!(arguments)
        rescue OptionParser::ParseError => error
          raise(Error, error.message, error.backtrace)
        end

      parse_matchers(patterns)
    end

    # Parse matchers
    #
    # @param [Enumerable<String>] patterns
    #
    # @return [undefined]
    #
    # @api private
    #
    def parse_matchers(patterns)
      patterns.each do |pattern|
        matcher = Classifier.run(@cache, pattern)
        @builder.add_matcher(matcher)
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
    def add_environmental_options(opts)
      opts.separator('')
      opts.separator('Environment:')
      opts.on('--zombie', 'Run mutant zombified') do
        @zombie = true
      end.on('-I', '--include DIRECTORY', 'Add DIRECTORY to $LOAD_PATH') do |directory|
        $LOAD_PATH << directory
      end.on('-r', '--require NAME', 'Require file with NAME') do |name|
        require(name)
      end
    end

    # Use plugin
    #
    # FIXME: For now all plugins are strategies. Later they could be anything that allows "late integration".
    #
    # @param [String] name
    #
    # @return [undefined]
    #
    # @api private
    #
    def use(name)
      require "mutant-#{name}"
      @strategy = Strategy.lookup(name).new
    rescue LoadError
      $stderr.puts("Cannot load plugin: #{name.inspect}")
      raise
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
        @expected_coverage = Float(coverage)
      end.on('--use STRATEGY', 'Use STRATEGY for killing mutations') do |runner|
        use(runner)
      end
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
        @builder.add_subject_ignore(Classifier.run(@cache, pattern))
      end
      opts.on('--code CODE', 'Scope execution to subjects with CODE') do |code|
        @builder.add_subject_selector(Morpher.compile(s(:eql, s(:attribute, :code), s(:static, code))))
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
        @fail_fast = true
      end.on('--version', 'Print mutants version') do |name|
        puts("mutant-#{Mutant::VERSION}")
        Kernel.exit(0)
      end.on('-d', '--debug', 'Enable debugging output') do
        @debug = true
      end.on_tail('-h', '--help', 'Show this message') do
        puts(opts)
        exit
      end
    end
  end # CLI
end # Mutant
