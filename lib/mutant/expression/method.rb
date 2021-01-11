# frozen_string_literal: true

module Mutant
  class Expression

    # Explicit method expression
    class Method < self
      extend AST::Sexp

      include Anima.new(
        :method_name,
        :scope_name,
        :scope_symbol
      )

      private(*anima.attribute_names)

      MATCHERS = {
        '.' => [Matcher::Methods::Singleton, Matcher::Methods::Metaclass].freeze,
        '#' => [Matcher::Methods::Instance].freeze
      }.freeze

      METHOD_NAME_PATTERN = /(?<method_name>.+)/.freeze

      private_constant(*constants(false))

      REGEXP = /\A#{SCOPE_NAME_PATTERN}#{SCOPE_SYMBOL_PATTERN}#{METHOD_NAME_PATTERN}\z/.freeze

      def initialize(*)
        super
        @syntax = [scope_name, scope_symbol, method_name].join.freeze
      end

      # Syntax of expression
      #
      # @return [String]
      attr_reader :syntax

      # Matcher for expression
      #
      # @return [Matcher]
      def matcher
        matcher_candidates = MATCHERS.fetch(scope_symbol)
          .map { |submatcher| submatcher.new(scope) }

        methods_matcher = Matcher::Chain.new(matcher_candidates)

        Matcher::Filter.new(methods_matcher, ->(subject) { subject.expression.eql?(self) })
      end

      def self.try_parse(input)
        match = REGEXP.match(input) or return

        from_match(match) if valid_method_name?(match[:method_name])
      end

      # Test if string is a valid Ruby method name
      #
      # Note that this crazyness is indeed the "correct" solution.
      #
      # See: https://github.com/whitequark/parser/issues/213
      #
      # @param [String]
      #
      # @return [Boolean]
      def self.valid_method_name?(name)
        buffer = ::Parser::Source::Buffer.new(nil, source: "def #{name}; end")

        ::Parser::CurrentRuby
          .new
          .parse(buffer).eql?(s(:def, name.to_sym, s(:args), nil))
      end
      private_class_method :valid_method_name?

    private

      def scope
        Object.const_get(scope_name)
      end

    end # Method
  end # Expression
end # Mutant
