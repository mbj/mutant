module Mutant
  # Comandline adapter or mutant runner
  class CLI
    include Immutable

    # Error raised when CLI argv is inalid
    Error = Class.new(RuntimeError)

    def self.run(*arguments)
      Runner.run(new(*arguments).runner_options)
    end

    def runner_options
      { 
        :mutation_filter => mutation_filter,
        :matcher         => matcher,
        :reporter        => Reporter::CLI.new($stderr),
        :killer          => Killer::Rspec
      }
    end
    memoize :runner_options

  private

    OPTIONS = {
      '--code' => [:add_filter, Mutation::Filter::Code].freeze
    }.deep_freeze

    OPTION_PATTERN = %r(\A-(?:-)?[a-z0-9]+\z).freeze

    def option(index)
      @arguments.fetch(index+1)
    end

    def initialize(arguments)
      @filters, @matchers = [], []

      @arguments = arguments

      @index = 0

      while @index < @arguments.length
        dispatch
      end
    end

    def current_argument
      @arguments.fetch(@index)
    end

    def current_option_value
      @arguments.fetch(@index+1)
    rescue IndexError
      raise Error,"#{current_argument.inspect} is missing an argument"
    end

    def dispatch
      if OPTION_PATTERN.match(current_argument)
        dispatch_option
      else
        dispatch_matcher
      end
    end

    def consume(amount)
      @index += amount
    end

    def dispatch_matcher
      argument = current_argument
      matcher = Mutant::Matcher.from_string(argument)

      unless matcher
        raise Error, "Invalid matcher syntax: #{argument.inspect}"
      end

      @matchers << matcher

      consume(1)
    end

    def dispatch_option
      argument = current_argument
      arguments = *OPTIONS.fetch(argument) do
        raise Error, "Unknown option: #{argument.inspect}"
      end
      send(*arguments)
    end

    def add_filter(klass)
      @filters << klass.new(current_option_value)
      consume(2)
    end

    def matcher
      if @matchers.empty?
        raise Error, 'No matchers given'
      end

      Mutant::Matcher::Chain.new(@matchers)
    end

    def mutation_filter
      if @filters.empty?
        Mutation::Filter::ALL
      else
        Mutation::Filter::Whitelist.new(@filters)
      end
    end

  end
end
