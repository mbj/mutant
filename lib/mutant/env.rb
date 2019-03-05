# frozen_string_literal: true

module Mutant
  # Abstract base class for mutant environments
  class Env
    include Adamantium::Flat, Anima.new(
      :config,
      :integration,
      :matchable_scopes,
      :mutations,
      :parser,
      :selector,
      :subjects,
      :world
    )

    SEMANTICS_MESSAGE =
      "Fix your lib to follow normal ruby semantics!\n" \
      '{Module,Class}#name should return resolvable constant name as String or nil'

    # Construct minimal empty env
    #
    # @param [World] world
    # @param [Config] config
    #
    # @return [Env]
    def self.empty(world, config)
      new(
        config:           config,
        integration:      Integration::Null.new(config),
        matchable_scopes: EMPTY_ARRAY,
        mutations:        EMPTY_ARRAY,
        parser:           Parser.new,
        selector:         Selector::Null.new,
        subjects:         EMPTY_ARRAY,
        world:            world
      )
    end

    # Kill mutation
    #
    # @param [Mutation] mutation
    #
    # @return [Result::Mutation]
    def kill(mutation)
      start = Timer.now

      tests = selections.fetch(mutation.subject)

      Result::Mutation.new(
        isolation_result: run_mutation_tests(mutation, tests),
        mutation:         mutation,
        runtime:          Timer.now - start
      )
    end

    # The test selections
    #
    # @return Hash{Mutation => Enumerable<Test>}
    def selections
      subjects.map do |subject|
        [subject, selector.call(subject)]
      end.to_h
    end
    memoize :selections

    # Emit warning
    #
    # @param [String] warning
    #
    # @return [self]
    def warn(message)
      config.reporter.warn(message)
      self
    end

  private

    # Kill mutation under isolation with integration
    #
    # @param [Mutation] mutation
    # @param [Array<Test>] test
    #
    # @return [Result::Isolation]
    def run_mutation_tests(mutation, tests)
      config.isolation.call do
        result = mutation.insert(world.kernel)

        if result.equal?(Loader::Result::VoidValue.instance)
          Result::Test::VoidValue.instance
        else
          integration.call(tests)
        end
      end
    end

  end # Env
end # Mutant
