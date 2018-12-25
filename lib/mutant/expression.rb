# frozen_string_literal: true

module Mutant

  # Abstract base class for match expression
  class Expression
    include AbstractType, Adamantium::Flat

    fragment             = /[A-Za-z][A-Za-z\d_]*/.freeze
    SCOPE_NAME_PATTERN   = /(?<scope_name>#{fragment}(?:#{SCOPE_OPERATOR}#{fragment})*)/.freeze
    SCOPE_SYMBOL_PATTERN = '(?<scope_symbol>[.#])'

    private_constant(*constants(false))

    # Syntax of expression
    #
    # @return [String]
    abstract_method :syntax

    # Match length with other expression
    #
    # @param [Expression] other
    #
    # @return [Integer]
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
    def self.try_parse(input)
      match = self::REGEXP.match(input)
      return unless match
      names = anima.attribute_names
      new(Hash[names.zip(names.map(&match.method(:[])))])
    end

  end # Expression
end # Mutant
