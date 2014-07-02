module Mutant
  # Abstract base class for mutant environments
  class Env
    include AbstractType, Adamantium

    # Return config
    #
    # @return [Config]
    #
    # @api private
    #
    abstract_method :config

    # Return cache
    #
    # @return [Cache]
    #
    # @api private
    #
    abstract_method :cache

    # Return reporter
    #
    # @return [Reporter]
    #
    # @api private
    #
    abstract_method :reporter

    # Print warning message
    #
    # @param [String]
    #
    # @return [self]
    #
    # @api private
    #
    def warn(message)
      reporter.warn(message)
      self
    end

    # Return all usable match scopes
    #
    # @return [Enumerable<Mutant::Matcher::Scope>]
    #
    # @api private
    #
    def matchable_scopes
      ObjectSpace.each_object(Module).each_with_object([]) do |scope, aggregate|
        expression = expression(scope)
        aggregate << Matcher::Scope.new(self, scope, expression) if expression
      end.sort_by(&:identification)
    end
    memoize :matchable_scopes, freezer: :noop

  private

    # Return scope name
    #
    # @param [Class, Module] scope
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
      warn("While optaining #{scope.class}#name from: #{scope.inspect} It raised an error: #{exception.inspect} fix your lib!")
      nil
    end

    # Try to turn scope into expression
    #
    # @param [Class, Module] scope
    #
    # @return [Expression]
    #   if scope can be represented in an expression
    #
    # @return [nil]
    #   otherwise
    #
    # @api private
    #
    def expression(scope)
      name = scope_name(scope) or return

      unless name.kind_of?(String)
        warn("#{scope.class}#name from: #{scope.inspect} did not return a String or nil.  Fix your lib to support normal ruby semantics!")
        return
      end

      Expression.try_parse(name)
    end

    # Boot environment used for matching
    class Boot < self
      include Concord::Public.new(:reporter, :cache)
    end # Boot

  end # ENV
end # Mutant
