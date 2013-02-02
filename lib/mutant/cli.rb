module Mutant

  # Comandline parser
  class CLI < CLIParser
    include Adamantium::Flat, Equalizer.new(:matcher, :filter, :strategy, :reporter)

    # Run cli with arguments
    #
    # @param [Array<String>] arguments
    #
    # @return [Fixnum]
    #   returns exit status
    #
    # @api private
    #
    def self.run(*arguments)
      config = new(*arguments)
      runner = Runner::Config.run(config)
      runner.success? ? EXIT_SUCCESS : EXIT_FAILURE
    rescue Error => exception
      $stderr.puts(exception.message)
      EXIT_FAILURE
    end

    OPTIONS = {
      '--code'       => [:add_filter,   Mutation::Filter::Code ],
      '--debug'      => [:set_debug                            ],
      '-d'           => [:set_debug                            ],
      '--rspec-unit' => [:set_strategy, Strategy::Rspec::Unit  ],
      '--rspec-full' => [:set_strategy, Strategy::Rspec::Full  ],
      '--rspec-dm2'  => [:set_strategy, Strategy::Rspec::DM2   ]
    }.freeze

    # Initialize objecct
    #
    # @param [Array<String>]
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(arguments)
      @filters, @matchers = [], []
      super(arguments)
      strategy
      matcher
    end

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
      @strategy || raise(Error, 'No strategy was set!')
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
      Mutant::Reporter::CLI.new(self)
    end
    memoize :reporter

  private

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

      Mutant::Matcher::Chain.build(@matchers)
    end
    memoize :matcher

    # Move processed argument by amount
    #
    # @param [Fixnum] amount
    #   the amount of arguments to be consumed
    #
    # @return [undefined]
    #
    # @api private
    #
    def consume(amount)
      @index += amount
    end

    # Process matcher argument
    # 
    # @return [undefined]
    #
    # @api private
    #
    def dispatch_matcher
      argument = current_argument
      consume(1)
      @matchers << Classifier.build(argument)
    end

    # Process option argument
    #
    # @return [Undefined]
    #
    # @api private
    #
    def dispatch_option
      argument = current_argument
      arguments = *OPTIONS.fetch(argument) do
        raise Error, "Unknown option: #{argument.inspect}"
      end
      send(*arguments)
    end

    # Add mutation filter
    #
    # @param [Class<Mutant::Filter>] klass
    #
    # @return [undefined]
    #
    # @api private
    #
    def add_filter(klass)
      @filters << klass.new(current_option_value)
      consume(2)
    end

    # Set debug mode
    #
    # @api private
    #
    # @return [undefined]
    #
    def set_debug
      consume(1)
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
      consume(1)
      @strategy = strategy
    end
  end
end
