module Mutant
  class Expression

    # Abstrat base class for methods expression
    class Methods < self

      MATCHERS = {
        '.' => Matcher::Methods::Singleton,
        '#' => Matcher::Methods::Instance
      }.freeze

      register(
        /\A(?<scope_name>#{SCOPE_PATTERN})(?<scope_symbol>[.#])\z/
      )

      # Return method matcher
      #
      # @param [Cache] cache
      #
      # @return [Matcher::Method]
      #
      # @api private
      #
      def matcher(cache)
        MATCHERS.fetch(scope_symbol).new(cache, scope)
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
        Mutant.constant_lookup(scope_name)
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
