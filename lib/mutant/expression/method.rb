module Mutant
  class Expression

    # Explicit method expression
    class Method < self

      MATCHERS = IceNine.deep_freeze(
        '.' => Matcher::Methods::Singleton,
        '#' => Matcher::Methods::Instance
      )

      register(
        /\A(?<scope_name>#{SCOPE_PATTERN})(?<scope_symbol>[.#])(?<method_name>#{METHOD_NAME_PATTERN})\z/
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
        methods_matcher = MATCHERS.fetch(scope_symbol).new(env, scope)
        method = methods_matcher.methods.detect do |meth|
          meth.name.equal?(method_name)
        end or fail NameError, "Cannot find method #{method_name}"
        methods_matcher.matcher.build(env, scope, method)
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

      # Return method name
      #
      # @return [String]
      #
      # @api private
      #
      def method_name
        match[__method__].to_sym
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
