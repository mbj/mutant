module Mutant
  class Matcher

    # Matcher for specific namespace
    class Namespace < self
      include Concord.new(:namespace)

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
          Scope.each(scope, &block)
        end

        self
      end

    private

      # Return pattern
      #
      # @return [Regexp]
      #
      # @api private
      #
      def pattern
        %r(\A#{Regexp.escape(namespace.name)}(?:::)?)
      end
      memoize :pattern

      # Return scope enumerator
      #
      # @return [Enumerable<Object>]
      #
      # @api private
      #
      def scopes(&block)
        return to_enum(__method__) unless block_given?

        ::ObjectSpace.each_object(Module).each do |scope|
          emit_scope(scope, &block)
        end
      end

      # Yield scope if name matches pattern
      #
      # @param [Module,Class] scope
      #
      # @return [undefined]
      #
      # @api private
      #
      def emit_scope(scope)
        if pattern =~ scope.name
          yield scope
        end
      end

    end
  end
end
