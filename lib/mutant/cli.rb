module Mutant
  # Comandline parser
  class CLI
    include Adamantium::Flat, Equalizer.new(:matcher, :filter, :killer)

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

    # Return killer
    #
    # @return [Mutant::Killer]
    #
    # @api private
    #
    def killer
      killer = Mutant::Killer::Rspec
      if @forking
        Mutant::Killer::Forking.new(killer)
      else
        killer
      end
    end
    memoize :killer

    # Return reporter
    #
    # @return [Mutant::Reporter::CLI]
    #
    # @api private
    #
    def reporter
      Mutant::Reporter::CLI.new($stderr)
    end
    memoize :reporter

  private

    OPTIONS = {
      '--code'    => [:add_filter, Mutation::Filter::Code],
      '-I'        => [:add_load_path],
      '--include' => [:add_load_path],
      '-r'        => [:require_library],
      '--require' => [:require_library],
      '--fork'    => [:set_forking]
    }.deep_freeze

    OPTION_PATTERN = %r(\A-(?:-)?[a-zA-Z0-9]+\z).freeze

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

      matcher
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
      if OPTION_PATTERN.match(current_argument)
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

    # Set forking
    #
    # @api private
    #
    # @return [self]
    #
    # @api private
    #
    def set_forking
      consume(1)
      @forking = true
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
