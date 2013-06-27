module Mutant
  class CLI
    class Classifier
      # Explicit method classifier
      class Method < self
        register

        TABLE = {
          '.' => Matcher::Methods::Singleton,
          '#' => Matcher::Methods::Instance
        }.freeze

        REGEXP = %r(\A(#{SCOPE_PATTERN})([.#])(#{METHOD_NAME_PATTERN}\z)).freeze

        # Positions of captured regexp groups
        SCOPE_NAME_POSITION   = 1
        SCOPE_SYMBOL_POSITION = 2
        METHOD_NAME_POSITION  = 3

        # Return method matcher
        #
        # @return [Matcher::Method]
        #
        # @api private
        #
        def matcher
          methods_matcher.matcher.new(cache, scope, method)
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
          end or raise("Cannot find method #{identification}")
        end
        memoize :method, :freezer => :noop

        # Return scope name
        #
        # @return [String]
        #
        # @api private
        #
        def scope_name
          match[SCOPE_NAME_POSITION]
        end

        # Return scope
        #
        # @return [Class, Method]
        #
        # @api private
        #
        def scope
          Classifier.constant_lookup(scope_name)
        end

        # Return method name
        #
        # @return [String]
        #
        # @api private
        #
        def method_name
          match[METHOD_NAME_POSITION].to_sym
        end

        # Return scope symbol
        #
        # @return [Symbol]
        #
        # @api private
        #
        def scope_symbol
          match[SCOPE_SYMBOL_POSITION]
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
