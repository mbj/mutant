module Mutant

  # Abstract base class for match expression
  class Expression
    include AbstractType, Adamantium::Flat

    fragment             = /[A-Za-z][A-Za-z\d_]*/.freeze
    SCOPE_NAME_PATTERN   = /(?<scope_name>#{fragment}(?:#{SCOPE_OPERATOR}#{fragment})*)/.freeze
    SCOPE_SYMBOL_PATTERN = '(?<scope_symbol>[.#])'.freeze

    private_constant(*constants(false))

    # Return syntax representing this expression
    #
    # @return [String]
    #
    # @api private
    #
    abstract_method :syntax

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

    # Try to parse input into expression of receiver class
    #
    # @param [String] input
    #
    # @return [Expression]
    #   when successful
    #
    # @return [nil]
    #   otherwise
    #
    # @api private
    def self.try_parse(input)
      match = self::REGEXP.match(input)
      return unless match
      names = anima.attribute_names
      new(Hash[names.zip(names.map(&match.method(:[])))])
    end

  end # Expression
end # Mutant
