# encoding: utf-8

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
        /\A#{Regexp.escape(namespace.name)}(?:::)?/
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

      # Return scope name
      #
      # @param [Class,Module] scope
      #
      # @return [String]
      #   if scope has a name and does not raise exceptions optaining it
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def self.scope_name(scope)
        scope.name
      rescue => exception
        $stderr.puts <<-MESSAGE
WARNING:
While optaining #{scope.class}#name from: #{scope.inspect}
It raised an error: #{exception.inspect} fix your lib!
        MESSAGE
        nil
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
        name = self.class.scope_name(scope)
        # FIXME: Fix nokogiri to return a string here
        unless name.nil? or name.kind_of?(String)
          $stderr.puts <<-MESSAGE
WARNING:
#{scope.class}#name did not return a string or nil.
Fix your lib!
          MESSAGE
        end
        if pattern =~ name
          yield scope
        end
      end

    end # Namespace
  end # Matcher
end # Mutant
