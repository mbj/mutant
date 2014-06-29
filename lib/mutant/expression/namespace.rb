module Mutant
  class Expression
    # Abstract base class for expressions matching namespaces
    class Namespace < self
      include AbstractType

    private

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
          namespace_src = Regexp.escape(namespace)
          @recursion_pattern = Regexp.union(
            /\A#{namespace_src}\z/,
            /\A#{namespace_src}::/,
            /\A#{namespace_src}[.#]/
          )
        end

        # Return matcher
        #
        # @param [Cache] cache
        #
        # @return [Matcher]
        #
        # @api private
        #
        def matcher(cache)
          Matcher::Namespace.new(cache, self)
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

      private

        # Return matched namespace
        #
        # @return [String]
        #
        # @api private
        #
        def namespace
          match[__method__] || ''
        end

      end # Recursive

      # Exact namespace expression
      class Exact < self

        register(/\A(?<namespace>#{SCOPE_PATTERN})\z/)

        MATCHER = Matcher::Scope

        # Return matcher
        #
        # @param [Cache] cache
        #
        # @return [Matcher]
        #
        # @api private
        #
        def matcher(cache)
          Matcher::Scope.new(cache, Mutant.constant_lookup(namespace))
        end

      private

        # Return namespace
        #
        # @return [String]
        #
        # @api private
        #
        def namespace
          match[__method__].to_s
        end

      end # Exact
    end # Namespace
  end # Namespace
end # Mutant
