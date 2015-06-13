module Mutant
  class Expression

    # Abstract base class for methods expression
    class Methods < self

      MATCHERS = IceNine.deep_freeze(
        '.' => Matcher::Methods::Singleton,
        '#' => Matcher::Methods::Instance
      )

      register(
        /\A(?<scope_name>#{SCOPE_PATTERN})(?<scope_symbol>[.#])\z/
      )

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

      # Return scope name
      #
      # @return [String]
      #
      # @api private
      #
      def scope_name
        match[__method__]
      end

      # Return scope
      #
      # @return [Class, Method]
      #
      # @api private
      #
      def scope
        Object.const_get(scope_name)
      end

      # Return scope symbol
      #
      # @return [Symbol]
      #
      # @api private
      #
      def scope_symbol
        match[__method__]
      end

    end # Method
  end # Expression
end # Mutant
