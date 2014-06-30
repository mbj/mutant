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
          scope.each(&block)
        end

        self
      end

    private

      # Return scope enumerator
      #
      # @return [Array<Class, Module>]
      #
      # @api private
      #
      def scopes
        ::ObjectSpace.each_object(Module).each_with_object([]) do |scope, aggregate|
          aggregate << Scope.new(cache, scope) if match?(scope)
        end.sort_by(&:identification)
      end
      memoize :scopes

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
      def scope_name(scope)
        scope.name
      rescue => exception
        $stderr.puts("WARNING: While optaining #{scope.class}#name from: #{scope.inspect} It raised an error: #{exception.inspect} fix your lib!")
        nil
      end

      # Test scope if name matches expresion
      #
      # @param [Module,Class] scope
      #
      # @return [Boolean]
      #
      # @api private
      #
      def match?(scope)
        name = scope_name(scope) or return false

        unless name.kind_of?(String)
          $stderr.puts("WARNING: #{scope.class}#name from: #{scope.inspect} did not return a String or nil.  Fix your lib to support normal ruby semantics!")
          return false
        end

        scope_expression = Expression.try_parse(name)

        unless scope_expression
          $stderr.puts("WARNING: #{name.inspect} is not an identifiable ruby class name.")
          return false
        end

        expression.prefix?(scope_expression)
      end

    end # Namespace
  end # Matcher
end # Mutant
