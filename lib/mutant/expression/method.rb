# frozen_string_literal: true

module Mutant
  class Expression

    # Explicit method expression
    class Method < self
      include Anima.new(
        :method_name,
        :scope_name,
        :scope_symbol
      )

      private(*anima.attribute_names)

      MATCHERS = IceNine.deep_freeze(
        '.' => Matcher::Methods::Singleton,
        '#' => Matcher::Methods::Instance
      )

      METHOD_NAME_PATTERN = Regexp.union(
        /(?<method_name>[A-Za-z_][A-Za-z\d_]*[!?=]?)/,
        *AST::Types::OPERATOR_METHODS.map(&:to_s)
      ).freeze

      private_constant(*constants(false))

      REGEXP = /\A#{SCOPE_NAME_PATTERN}#{SCOPE_SYMBOL_PATTERN}#{METHOD_NAME_PATTERN}\z/.freeze

      # Syntax of expression
      #
      # @return [String]
      def syntax
        [scope_name, scope_symbol, method_name].join
      end
      memoize :syntax

      # Matcher for expression
      #
      # @return [Matcher]
      def matcher
        methods_matcher = MATCHERS.fetch(scope_symbol).new(scope)

        Matcher::Filter.new(methods_matcher, ->(subject) { subject.expression.eql?(self) })
      end

    private

      # Scope object
      #
      # @return [Class, Method]
      def scope
        Object.const_get(scope_name)
      end

    end # Method
  end # Expression
end # Mutant
