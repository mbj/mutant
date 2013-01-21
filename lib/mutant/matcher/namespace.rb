module Mutant
  class Matcher
    # Matcher for specific namespace
    class Namespace < self
      include Equalizer.new(:pattern)

      # Enumerate subjects
      #
      # @return [self]
      #   if block given
      #
      # @return [Enumerator<Subject>]
      #   otherwise
      #
      # @api private
      #
      def each(&block)
        return to_enum unless block_given?

        scopes.each do |scope|
          emit_scope_matches(scope, &block)
        end

        self
      end

      # Return namespace
      #
      # @return [Class::Module]
      #
      # @api private
      #
      attr_reader :namespace

      MATCHERS = [Matcher::Methods::Singleton, Matcher::Methods::Instance]

    private

      # Initialize object space matcher 
      #
      # @param [Class, Module] namespace
      #
      # @return [undefined]
      #
      # @api private
      #
      def initialize(namespace)
        @namespace = namespace
      end

      # Return pattern
      #
      # @return [Regexp]
      #
      # @api private
      #
      def pattern
        %r(\A#{Regexp.escape(namespace_name)}(?:::)?\z)
      end
      memoize :pattern

      # Yield matchers for scope
      #
      # @param [::Class,::Module] scope
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_scope_matches(scope, &block)
        MATCHERS.each do |matcher|
          matcher.new(scope).each(&block)
        end
      end

      # Return scope enumerator
      #
      # @return [Enumerable<Object>]
      #
      # @api private
      #
      def scopes(&block)
        return to_enum(__method__) unless block_given?

        ::ObjectSpace.each_object(Module) do |scope|
          emit_scope(scope, &block)
        end
      end

      # Yield scope if name matches pattern
      #
      # @param [::Module,::Class] scope
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_scope(scope)
        if [::Module, ::Class].include?(scope.class) and pattern =~ scope.name 
          yield scope 
        end
      end
    end
  end
end
