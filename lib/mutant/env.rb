module Mutant
  # Abstract base class for mutant environments
  class Env
    include Adamantium, Concord::Public.new(:config, :cache), Procto.call(:run)

    # Return new env
    #
    # @param [Config] config
    #
    # @return [Env]
    #
    # @api private
    #
    def self.new(config)
      super(config, Cache.new)
    end

    # Initialize env
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(*)
      super

      infect
      initialize_matchable_scopes
      initialize_subjects
    end

    # Run mutant producing a report on configured env
    #
    # @return [Report]
    #
    # @api private
    #
    def run
      Runner.call(self)
    end

    # Print warning message
    #
    # @param [String]
    #
    # @return [self]
    #
    # @api private
    #
    def warn(message)
      config.reporter.warn(message)
      self
    end

    # Return subjects
    #
    # @return [Array<Subject>]
    #
    # @api private
    #
    attr_reader :subjects

    # Return all usable match scopes
    #
    # @return [Array<Matcher::Scope>]
    #
    # @api private
    #
    attr_reader :matchable_scopes

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

    # Initialize subjects
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize_subjects
      @subjects = Matcher::Compiler.call(self, config.matcher_config).to_a
    end

    # Infect environment
    #
    # @return [undefined]
    #
    # @api private
    #
    def infect
      config.includes.each(&$LOAD_PATH.method(:<<))
      config.requires.each(&method(:require))
    end

    # Initialize matchable scopes
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize_matchable_scopes
      @matchable_scopes = ObjectSpace.each_object(Module).each_with_object([]) do |scope, aggregate|
        expression = expression(scope)
        aggregate << Matcher::Scope.new(self, scope, expression) if expression
      end.sort_by(&:identification)
    end

  end # Env
end # Mutant
