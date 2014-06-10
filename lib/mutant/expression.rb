module Mutant

  # Abstract base class for match expression
  class Expression
    include AbstractType, Adamantium, Concord::Public.new(:match)

    include Equalizer.new(:syntax)

    SCOPE_NAME_PATTERN = /[A-Za-z][A-Za-z\d_]*/.freeze

    METHOD_NAME_PATTERN = Regexp.union(
      /[A-Za-z_][A-Za-z\d_]*[!?=]?/,
      *OPERATOR_METHODS.map(&:to_s)
    ).freeze

    SCOPE_PATTERN = /#{SCOPE_NAME_PATTERN}(?:#{SCOPE_OPERATOR}#{SCOPE_NAME_PATTERN})*/.freeze

    REGISTRY = {}

    # Initialize expression
    #
    # @param [MatchData] match
    #
    # @api private
    #
    def initialize(*)
      super
      @syntax = match.to_s
    end

    # Return syntax
    #
    # @return [String]
    #
    # @api private
    #
    attr_reader :syntax

    # Return match length for expression
    #
    # @param [Expression] neddle
    #
    # @return [Fixnum]
    #
    # @api private
    #
    def match_length(neddle)
      if eql?(neddle)
        syntax.length
      else
        0
      end
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

    # Parse input into expression
    #
    # @param [String] pattern
    #
    # @return [Expression]
    #   if expression is valid
    #
    # @return [nil]
    #   otherwise
    #
    # @api private
    #
    def self.parse(pattern)
      expressions = expressions(pattern)
      case expressions.length
      when 0
      when 1
        expressions.first
      else
        fail "Ambigous expression: #{pattern.inspect}"
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
