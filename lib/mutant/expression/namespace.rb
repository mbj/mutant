module Mutant
  class Expression
    # Abstract base class for expressions matching namespaces
    class Namespace < self
      include AbstractType

      # Return matcher
      #
      # @param [Cache] cache
      #
      # @return [Matcher]
      #
      # @api private
      #
      def matcher(cache)
        self.class::MATCHER.new(cache, namespace)
      end

    private

      # Return namespace
      #
      # @return [Class, Module]
      #
      # @api private
      #
      def namespace
        Mutant.constant_lookup(match[__method__].to_s)
      end

      # Recursive namespace expression
      class Recursive < self

        register(/\A(?<namespace>#{SCOPE_PATTERN})\*\z/)

        MATCHER = Matcher::Namespace

        # Initialize object
        #
        # @return [undefined]
        #
        # @api private
        def initialize(*)
          super
          namespace_src = Regexp.escape(match[:namespace])
          @recursion_pattern = Regexp.union(/\A#{namespace_src}\z/, /\A#{namespace_src}::/)
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
            match[:namespace].length
          else
            0
          end
        end

      end # Recursive

      # Exact namespace expression
      class Exact < self

        register(/\A(?<namespace>#{SCOPE_PATTERN})\z/)

        MATCHER = Matcher::Scope

      end # Exact

    end # Namespace
  end # Namespace
end # Mutant
