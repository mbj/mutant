module Mutant
  # Comandline adapter or mutant runner
  class CLI
    include Immutable

    # Error raised when CLI argv is inalid
    Error = Class.new(RuntimeError)

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
      error = Runner.run(new(*arguments).runner_options).fail?
      error ? 1 : 0
    end

    # Return options for runner
    #
    # @return [Hash]
    #
    # @api private
    #
    def runner_options
      { 
        :mutation_filter => mutation_filter,
        :matcher         => matcher,
        :reporter        => Reporter::CLI.new($stderr),
        :killer          => Killer::Rspec::Forking
      }
    end
    memoize :runner_options

  private

    OPTIONS = {
      '--code' => [:add_filter, Mutation::Filter::Code].freeze
    }.deep_freeze

    OPTION_PATTERN = %r(\A-(?:-)?[a-z0-9]+\z).freeze

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

      @arguments = arguments

      @index = 0

      while @index < @arguments.length
        dispatch
      end
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
      raise Error,"#{current_argument.inspect} is missing an argument"
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

      Mutant::Matcher::Chain.new(@matchers)
    end

    # Return mutation filter
    #
    # @return [Mutant::Matcher]
    #
    # @api private
    #
    def mutation_filter
      if @filters.empty?
        Mutation::Filter::ALL
      else
        Mutation::Filter::Whitelist.new(@filters)
      end
    end

  end
end
