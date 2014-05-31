# encoding: utf-8

module Mutant
  class CLI
    class Classifier

      # Explicit method classifier
      class Method < self

        TABLE = {
          '.' => Matcher::Methods::Singleton,
          '#' => Matcher::Methods::Instance
        }.freeze

        REGEXP = /
          \A
            (?<scope_name>#{SCOPE_PATTERN})
            (?<scope_symbol>[.#])
            (?<method_name>#{METHOD_NAME_PATTERN})
          \z
        /x.freeze

        register(REGEXP)

        # Return method matcher
        #
        # @return [Matcher::Method]
        #
        # @api private
        #
        def matcher
          methods_matcher.matcher.build(cache, scope, method)
        end
        memoize :matcher

      private

        # Return method
        #
        # @return [Method, UnboundMethod]
        #
        # @api private
        #
        def method
          methods_matcher.methods.detect do |method|
            method.name == method_name
          end or raise NameError, "Cannot find method #{identifier}"
        end
        memoize :method, freezer: :noop

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
        def methods_matcher
          TABLE.fetch(scope_symbol).new(cache, scope)
        end
        memoize :methods_matcher

      end # Method
    end # Classifier
  end # CLI
end # Mutant
