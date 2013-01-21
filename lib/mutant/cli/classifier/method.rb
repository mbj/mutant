module Mutant
  class CLI
    class Classifier
      # Explicit method classifier
      class Method < self

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
          # TODO: Honor law of demeter
          scope_matcher.matcher.new(scope, method)
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
          # TODO: Honor law of demeter
          scope_matcher.methods.detect do |method|
            method.name == method_name
          end || raise("Cannot find #{method_name} for #{scope}")
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
        def scope_matcher
          TABLE.fetch(scope_symbol).new(scope)
        end
        memoize :scope_matcher

      end
    end
  end
end
