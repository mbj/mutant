module Mutant

  # Abstract base class for match expression
  class Expression
    include AbstractType, Adamantium::Flat, Concord::Public.new(:match)

    include Equalizer.new(:syntax)

    SCOPE_NAME_PATTERN = /[A-Za-z][A-Za-z\d_]*/.freeze

    METHOD_NAME_PATTERN = Regexp.union(
      /[A-Za-z_][A-Za-z\d_]*[!?=]?/,
      *AST::Types::OPERATOR_METHODS.map(&:to_s)
    ).freeze

    INSPECT_FORMAT = '<Mutant::Expression: %s>'.freeze

    SCOPE_PATTERN = /#{SCOPE_NAME_PATTERN}(?:#{SCOPE_OPERATOR}#{SCOPE_NAME_PATTERN})*/.freeze

    REGISTRY = {}

    # Error raised on invalid expressions
    class InvalidExpressionError < RuntimeError; end

    # Error raised on ambiguous expressions
    class AmbiguousExpressionError < RuntimeError; end

    # Initialize expression
    #
    # @param [MatchData] match
    #
    # @api private
    #
    def initialize(*)
      super
      @syntax = match.to_s
      @inspect = format(INSPECT_FORMAT, syntax)
    end

    # Return inspection
    #
    # @return [String]
    #
    # @api private
    #
    attr_reader :inspect

    # Return syntax
    #
    # @return [String]
    #
    # @api private
    #
    attr_reader :syntax

    # Return match length for expression
    #
    # @param [Expression] other
    #
    # @return [Fixnum]
    #
    # @api private
    #
    def match_length(other)
      if eql?(other)
        syntax.length
      else
        0
      end
    end

    # Test if expression is prefix
    #
    # @param [Expression] other
    #
    # @return [Boolean]
    #
    # @api private
    #
    def prefix?(other)
      !match_length(other).zero?
    end

    # Register expression
    #
    # @return [undefined]
    #
    # @api private
    #
    def self.register(regexp)
      REGISTRY[regexp] = self
    end
    private_class_method :register

    # Parse input into expression or raise
    #
    # @param [String] syntax
    #
    # @return [Expression]
    #   if expression is valid
    #
    # @raise [RuntimeError]
    #   otherwise
    #
    # @api private
    #
    def self.parse(input)
      try_parse(input) or fail InvalidExpressionError, "Expression: #{input.inspect} is not valid"
    end

    # Parse input into expression
    #
    # @param [String] input
    #
    # @return [Expression]
    #   if expression is valid
    #
    # @return [nil]
    #   otherwise
    #
    # @api private
    #
    def self.try_parse(input)
      expressions = expressions(input)
      case expressions.length
      when 0
      when 1
        expressions.first
      else
        fail AmbiguousExpressionError, "Ambiguous expression: #{input.inspect}"
      end
    end

    # Return expressions for input
    #
    # @param [String] input
    #
    # @return [Classifier]
    #   if classifier can be found
    #
    # @return [nil]
    #   otherwise
    #
    # @api private
    #
    def self.expressions(input)
      REGISTRY.each_with_object([]) do |(regexp, klass), expressions|
        match = regexp.match(input)
        next unless match
        expressions << klass.new(match)
      end
    end
    private_class_method :expressions

  end # Expression
end # Mutant
