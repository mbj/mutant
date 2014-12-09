module Mutant
  # Abstract base class for mutant environments
  class Env
    include Adamantium::Flat, Concord::Public.new(:config, :cache)

    SEMANTICS_MESSAGE =
      "Fix your lib to follow normal ruby semantics!\n" \
      '{Module,Class}#name should return resolvable constant name as String or nil'.freeze

    # Return new env
    #
    # @param [Config] config
    #
    # @return [Env]
    #
    # @api private
    #
    def self.new(config, cache = Cache.new)
      super(config, cache)
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
      initialize_mutations
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

    # Return mutations
    #
    # @return [Array<Mutation>]
    #
    # @api private
    #
    attr_reader :mutations

    # Return all usable match scopes
    #
    # @return [Array<Matcher::Scope>]
    #
    # @api private
    #
    attr_reader :matchable_scopes

    # Kill mutation
    #
    # @param [Mutation] mutation
    #
    # @return [Result::Mutation]
    #
    # @api private
    #
    def kill_mutation(mutation)
      test_result = mutation.kill(config.isolation, config.integration)
      Result::Mutation.new(
        mutation:    mutation,
        test_result: test_result
      )
    end

  private

    # Return scope name
    #
    # @param [Class, Module] scope
    #
    # @return [String]
    #   if scope has a name and does not raise exceptions obtaining it
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
      warn("#{scope.class}#name from: #{scope.inspect} raised an error: #{exception.inspect}. #{SEMANTICS_MESSAGE}")
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

      unless name.is_a?(String)
        warn("#{scope.class}#name from: #{scope.inspect} returned #{name.inspect}. #{SEMANTICS_MESSAGE}")
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

    # Initialize mutations
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize_mutations
      @mutations = subjects.flat_map(&:mutations)
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
