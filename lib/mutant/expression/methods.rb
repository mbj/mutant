# frozen_string_literal: true

module Mutant
  class Expression

    # Abstract base class for methods expression
    class Methods < self
      include Anima.new(
        :scope_name,
        :scope_symbol
      )

      private(*anima.attribute_names)

      MATCHERS = IceNine.deep_freeze(
        '.' => [Matcher::Methods::Singleton, Matcher::Methods::Metaclass],
        '#' => [Matcher::Methods::Instance]
      )
      private_constant(*constants(false))

      REGEXP = /\A#{SCOPE_NAME_PATTERN}#{SCOPE_SYMBOL_PATTERN}\z/.freeze

      def initialize(*)
        super
        @syntax = [scope_name, scope_symbol].join.freeze
      end

      # Syntax of expression
      #
      # @return [String]
      attr_reader :syntax

      # Matcher on expression
      #
      # @return [Matcher::Method]
      def matcher
        matcher_candidates = MATCHERS.fetch(scope_symbol)
          .map { |submatcher| submatcher.new(scope) }

        Matcher::Chain.new(matcher_candidates)
      end

      # Length of match with other expression
      #
      # @param [Expression] expression
      #
      # @return [Integer]
      def match_length(expression)
        if expression.syntax.start_with?(syntax)
          syntax.length
        else
          0
        end
      end

    private

      def scope
        Object.const_get(scope_name)
      end

    end # Methods
  end # Expression
end # Mutant
