module Mutant
  # Base class for cli parsers
  #
  # I hate base classes for reusable functionallity.
  # But could not come up with a nice composition/instantiation
  # solution.
  #
  class CLIParser

    # Error raised when CLI argv is inalid
    Error = Class.new(RuntimeError)

    EXIT_FAILURE = 1
    EXIT_SUCCESS = 0

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
      @arguments, @index = arguments, 0
      while @index < @arguments.length
        dispatch
      end
    end

  private

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

  end
end
