module Mutant
  class Expression

    # Abstract base class for methods expression
    class Methods < self
      include Anima.new(:scope_name, :scope_symbol)
      private(*anima.attribute_names)

      MATCHERS = IceNine.deep_freeze(
        '.' => Matcher::Methods::Singleton,
        '#' => Matcher::Methods::Instance
      )
      private_constant(*constants(false))

      REGEXP = /\A#{SCOPE_NAME_PATTERN}#{SCOPE_SYMBOL_PATTERN}\z/.freeze

      # Return syntax
      #
      # @return [String]
      #
      # @api private
      #
      def syntax
        [scope_name, scope_symbol].join
      end
      memoize :syntax

      # Return method matcher
      #
      # @param [Env] env
      #
      # @return [Matcher::Method]
      #
      # @api private
      #
      def matcher(env)
        MATCHERS.fetch(scope_symbol).new(env, scope)
      end

      # Return length of match
      #
      # @param [Expression] expression
      #
      # @return [Fixnum]
      #
      # @api private
      #
      def match_length(expression)
        if expression.syntax.start_with?(syntax)
          syntax.length
        else
          0
        end
      end

    private

      # Return scope
      #
      # @return [Class, Method]
      #
      # @api private
      #
      def scope
        Object.const_get(scope_name)
      end

    end # Method
  end # Expression
end # Mutant
