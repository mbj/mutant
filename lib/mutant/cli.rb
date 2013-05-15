require 'optparse'

module Mutant

  # Comandline parser
  class CLI
    include Adamantium::Flat, Equalizer.new(:config)

    # Error raised when CLI argv is inalid
    Error = Class.new(RuntimeError)

    EXIT_FAILURE = 1
    EXIT_SUCCESS = 0

    # Run cli with arguments
    #
    # @param [Array<String>] arguments
    #
    # @return [Fixnum]
    #   returns exit status
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

    # Initialize objecct
    #
    # @param [Array<String>]
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(arguments=[])
      @filters, @matchers = [], []

      parse(arguments)
      strategy
      matcher
    end

    # Return config
    #
    # @return [Config]
    #
    # @api private
    #
    def config
      Config.new(
        :debug    => debug?,
        :matcher  => matcher,
        :filter   => filter,
        :strategy => strategy,
        :reporter => reporter
      )
    end
    memoize :config

  private

    # Test for running in debug mode
    #
    # @return [true]
    #   if debug mode is active
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    def debug?
      !!@debug
    end

    # Return mutation filter
    #
    # @return [Mutant::Matcher]
    #
    # @api private
    #
    def filter
      if @filters.empty?
        Mutation::Filter::ALL
      else
        Mutation::Filter::Whitelist.new(@filters)
      end
    end
    memoize :filter

    # Return stratety
    #
    # @return [Strategy]
    #
    # @api private
    #
    def strategy
      @strategy or raise(Error, 'No strategy was set!')
      @strategy.new(self)
    end
    memoize :strategy

    # Return reporter
    #
    # @return [Mutant::Reporter::CLI]
    #
    # @api private
    #
    def reporter
      Reporter::CLI.new($stdout)
    end
    memoize :reporter

    # Return matcher
    #
    # @return [Mutant::Matcher]
    #
    # @raise [CLI::Error]
    #   raises error when matcher is not given
    #
    # @api private
    #
    def matcher
      if @matchers.empty?
        raise Error, 'No matchers given'
      end

      Matcher::Chain.build(@matchers)
    end
    memoize :matcher

    # Add mutation filter
    #
    # @param [Class<Mutant::Filter>] klass
    #
    # @param [String] filter
    #
    # @return [undefined]
    #
    # @api private
    #
    def add_filter(klass,filter)
      @filters << klass.new(filter)
    end

    # Set debug mode
    #
    # @api private
    #
    # @return [undefined]
    #
    def set_debug
      @debug = true
    end

    # Set strategy
    #
    # @param [Strategy] strategy
    #
    # @api private
    #
    # @return [undefined]
    #
    def set_strategy(strategy)
      @strategy = strategy
    end

    # Parses the command-line options.
    #
    # @param [Array<String>] arguments
    #   Command-line options and arguments to be parsed.
    #
    # @raise [Error]
    #   An error occurred while parsing the options.
    #
    # @api private
    #
    def parse(arguments)
      opts = OptionParser.new do |opts|
        opts.banner = 'usage: mutant STRATEGY [options] MATCHERS ...'

        opts.separator ''
        opts.separator 'Strategies:'

        opts.on('--rspec-unit','executes all specs under ./spec/unit') do
          set_strategy Strategy::Rspec::Unit
        end

        opts.on('--rspec-full','executes all specs under ./spec') do
          set_strategy Strategy::Rspec::Full
        end

        opts.on('--rspec-dm2','executes spec/unit/namespace/class/method_spec.rb') do
          set_strategy Strategy::Rspec::DM2
        end

        opts.separator ''
        opts.separator 'Options:'

        opts.on('--code FILTER','Adds a code filter') do |filter|
          add_filter Mutation::Filter::Code, filter
        end

        opts.on('-d','--debug','Enable debugging output') do
          set_debug
        end

        opts.on_tail('-h','--help','Show this message') do
          puts opts
          exit
        end
      end

      matchers = begin
                   opts.parse!(arguments)
                 rescue OptionParser::ParseError => e
                   raise(Error,e.message,e.backtrace)
                 end

      matchers.each do |pattern|
        matcher = Classifier.build(pattern)
        @matchers << matcher if matcher
      end
    end
  end
end
