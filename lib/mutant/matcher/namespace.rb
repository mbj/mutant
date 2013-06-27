module Mutant
  class Matcher

    # Matcher for specific namespace
    class Namespace < self
      include Concord::Public.new(:cache, :namespace)

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
          Scope.each(cache, scope, &block)
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

      # Test for bogus class
      #
      # FIXME: Remove this hack once bogus is fixed!
      #
      # @param [Object] object
      #
      # @return [true]
      #   if is a bogous class
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def self.bogous?(object)
        defined?(Bogus::Fake) && object == Bogus::Fake
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
        return if self.class.bogous?(scope)
        name = scope.name
        # FIXME Fix nokogiri!
        return unless name.kind_of?(String)
        if pattern =~ scope.name
          yield scope
        end
      end

    end # Namespace
  end # Matcher
end # Mutant
