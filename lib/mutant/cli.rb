module Mutant
  # Comandline parser
  class CLI
    include Adamantium::Flat, Equalizer.new(:matcher, :filter, :strategy, :reporter)

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
    def self.run(*arguments)
      error = Runner.run(new(*arguments)).fail?
      error ? EXIT_FAILURE : EXIT_SUCCESS
    rescue Error => exception
      $stderr.puts(exception.message)
      EXIT_FAILURE
    end

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
      @strategy || raise(Error, 'no strategy was set!')
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

    OPTIONS = {
      '--code'               => [:add_filter,           Mutation::Filter::Code    ],
      '-I'                   => [:add_load_path                                   ],
      '--include'            => [:add_load_path                                   ],
      '-r'                   => [:require_library                                 ],
      '--require'            => [:require_library                                 ],
      '--debug'              => [:set_debug                                       ],
      '-d'                   => [:set_debug                                       ],
      '--rspec-unit'         => [:set_strategy,         Strategy::Rspec::Unit     ],
      '--rspec-full'         => [:set_strategy,         Strategy::Rspec::Full     ],
      '--rspec-dm2'          => [:set_strategy,         Strategy::Rspec::DM2      ],
      '--static-fail'        => [:set_strategy,         Strategy::Static::Fail    ],
      '--static-success'     => [:set_strategy,         Strategy::Static::Success ]
    }.freeze

    OPTION_PATTERN = %r(\A-(?:-)?[a-zA-Z0-9\-]+\z).freeze

    # Initialize CLI 
    #
    # @param [Array<String>] arguments
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(arguments)
      @filters, @matchers = [], []

      @arguments, @index = arguments, 0

      while @index < @arguments.length
        dispatch
      end

      strategy
      matcher
    end

    # Return option for argument with index
    #
    # @param [Fixnum] index
    #
    # @return [String]
    #
    # @api private
    #
    def option(index)
      @arguments.fetch(index+1)
    end

    # Return current argument
    #
    # @return [String]
    #
    # @api private
    #
    def current_argument
      @arguments.fetch(@index)
    end

    # Return current option value
    #
    # @return [String]
    #
    # @raise [CLI::Error]
    #   raises error when option is missing
    #
    # @api private
    #
    def current_option_value
      @arguments.fetch(@index+1)
    rescue IndexError
      raise Error, "#{current_argument.inspect} is missing an argument"
    end

    # Process current argument
    #
    # @return [undefined]
    #
    # @api private
    #
    def dispatch
      if OPTION_PATTERN =~ current_argument
        dispatch_option
      else
        dispatch_matcher
      end
    end

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
      matcher = Mutant::Matcher.from_string(argument)

      unless matcher
        raise Error, "Invalid matcher syntax: #{argument.inspect}"
      end

      @matchers << matcher

      consume(1)
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
    # @param [Class<Mutant::Filter>]
    #
    # @return [undefined]
    #
    # @api private
    #
    def add_filter(klass)
      @filters << klass.new(current_option_value)
      consume(2)
    end

    # Add load path
    #
    # @api private
    #
    # @return [undefined]
    #
    def add_load_path
      $LOAD_PATH << current_option_value
      consume(2)
    end

    # Enable rspec
    #
    # @api private
    #
    # @return [self]
    #
    # @api private
    #
    def enable_rspec
      consume(1)
      @rspec = true
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
    # @param [Strategy]
    #
    # @api private
    #
    # @return [undefined]
    #
    def set_strategy(strategy)
      consume(1)
      @strategy = strategy
    end

    # Require library
    #
    # @api private
    # 
    # @return [undefined]
    #
    def require_library
      require(current_option_value)
      consume(2)
    end
  end
end
