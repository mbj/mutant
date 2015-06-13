module Mutant
  class Expression
    # Abstract base class for expressions matching namespaces
    class Namespace < self
      include AbstractType

    private

      # Return matched namespace
      #
      # @return [String]
      #
      # @api private
      #
      def namespace
        match[__method__]
      end

      # Recursive namespace expression
      class Recursive < self

        register(/\A(?<namespace>#{SCOPE_PATTERN})?\*\z/)

        # Initialize object
        #
        # @return [undefined]
        #
        # @api private
        def initialize(*)
          super
          @recursion_pattern = Regexp.union(
            /\A#{namespace}\z/,
            /\A#{namespace}::/,
            /\A#{namespace}[.#]/
          )
        end

        # Return matcher
        #
        # @param [Env::Bootstrap] env
        #
        # @return [Matcher]
        #
        # @api private
        #
        def matcher(env)
          Matcher::Namespace.new(env, self)
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
          if @recursion_pattern =~ expression.syntax
            namespace.length
          else
            0
          end
        end

      end # Recursive

      # Exact namespace expression
      class Exact < self

        register(/\A(?<namespace>#{SCOPE_PATTERN})\z/)

        MATCHER = Matcher::Scope

        # Return matcher
        #
        # @param [Env::Bootstrap] env
        #
        # @return [Matcher]
        #
        # @api private
        #
        def matcher(env)
          Matcher::Scope.new(env, Object.const_get(namespace), self)
        end

      end # Exact
    end # Namespace
  end # Namespace
end # Mutant
