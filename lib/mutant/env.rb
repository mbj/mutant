module Mutant
  # Abstract base class for mutant environments
  class Env
    include Adamantium::Flat, Anima::Update, Anima.new(
      :config,
      :actor_env,
      :cache,
      :subjects,
      :matchable_scopes,
      :mutations
    )

    SEMANTICS_MESSAGE =
      "Fix your lib to follow normal ruby semantics!\n" \
      '{Module,Class}#name should return resolvable constant name as String or nil'.freeze

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

  end # Env
end # Mutant
