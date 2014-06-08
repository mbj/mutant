module Mutant
  class Expression

    # Explicit method expression
    class Method < self

      MATCHERS = {
        '.' => Matcher::Methods::Singleton,
        '#' => Matcher::Methods::Instance
      }.freeze

      register(
        /\A(?<scope_name>#{SCOPE_PATTERN})(?<scope_symbol>[.#])(?<method_name>#{METHOD_NAME_PATTERN})\z/
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
        methods_matcher = MATCHERS.fetch(scope_symbol).new(cache, scope)
        method = methods_matcher.methods.detect do |meth|
          meth.name == method_name
        end or raise NameError, "Cannot find method #{identifier}"
        methods_matcher.matcher.build(cache, scope, method)
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

      # Return matcher class
      #
      # @return [Class:Mutant::Matcher]
      #
      # @api private
      #
      def methods_matcher(cache)
        MATCHERS.fetch(scope_symbol).new(cache, scope)
      end

    end # Method
  end # Expression
end # Mutant
