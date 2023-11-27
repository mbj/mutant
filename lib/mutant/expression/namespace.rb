# frozen_string_literal: true

module Mutant
  class Expression
    # Abstract base class for expressions matching namespaces
    class Namespace < self
      include AbstractType, Anima.new(:scope_name)
      private(*anima.attribute_names)

      # Recursive namespace expression
      class Recursive < self
        REGEXP = /\A#{SCOPE_NAME_PATTERN}?\*\z/

        # Initialize object
        #
        # @return [undefined]
        def initialize(*)
          super

          @syntax = "#{scope_name}*".freeze

          @recursion_pattern = Regexp.union(
            /\A#{scope_name}\z/,
            /\A#{scope_name}::/,
            /\A#{scope_name}[.#]/
          )
        end

        # Syntax for expression
        #
        # @return [String]
        attr_reader :syntax

        # Matcher for expression
        #
        # @return [Matcher]
        def matcher
          Matcher::Namespace.new(expression: self)
        end

        # Length of match with other expression
        #
        # @param [Expression] expression
        #
        # @return [Integer]
        def match_length(expression)
          if eql?(expression)
            syntax.length
          elsif @recursion_pattern.match?(expression.syntax)
            scope_name.length
          else
            0
          end
        end
      end # Recursive

      # Exact namespace expression
      class Exact < self

        MATCHER = Matcher::Scope
        private_constant(*constants(false))

        REGEXP = /\A#{SCOPE_NAME_PATTERN}\z/

        # Matcher matcher on expression
        #
        # @return [Matcher]
        def matcher
          scope = find_scope

          if scope
            Matcher::Scope.new(scope: scope)
          else
            Matcher::Null.new
          end
        end

        # Syntax for expression
        #
        # @return [String]
        alias_method :syntax, :scope_name
        public :syntax

      private

        def find_scope
          Object.const_get(scope_name)
        rescue NameError # rubocop:disable Lint/SuppressedException
        end
      end # Exact
    end # Namespace
  end # Expression
end # Mutant
