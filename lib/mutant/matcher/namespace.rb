module Mutant
  class Matcher

    # Matcher for specific namespace
    #
    # rubocop:disable LineLength
    class Namespace < self
      include Concord::Public.new(:cache, :expression)

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
          Scope.new(cache, scope).each(&block)
        end

        self
      end

    private

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
      # rubocop:disable LineLength
      #
      def self.scope_name(scope)
        scope.name
      rescue => exception
        $stderr.puts("WARNING: While optaining #{scope.class}#name from: #{scope.inspect} It raised an error: #{exception.inspect} fix your lib!")
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

        return if name.nil?

        unless name.kind_of?(String)
          $stderr.puts("WARNING: #{scope.class}#name from: #{scope.inspect} did not return a String or nil.  Fix your lib to support normal ruby semantics!")
          return
        end

        scope_expression = Expression.parse(name)

        unless scope_expression
          $stderr.puts("WARNING: #{name.inspect} is not an identifiable ruby class name.")
          return
        end

        yield scope if expression.prefix?(scope_expression)
      end

    end # Namespace
  end # Matcher
end # Mutant
