module Mutant
  # Abstract base class for mutant environments
  class Env
    include Adamantium::Flat, Anima.new(
      :actor_env,
      :config,
      :integration,
      :matchable_scopes,
      :mutations,
      :parser,
      :selector,
      :subjects
    )

    SEMANTICS_MESSAGE =
      "Fix your lib to follow normal ruby semantics!\n" \
      '{Module,Class}#name should return resolvable constant name as String or nil'.freeze

    # Kill mutation
    #
    # @param [Mutation] mutation
    #
    # @return [Result::Mutation]
    def kill(mutation)
      test_result = run_mutation_tests(mutation)
      Result::Mutation.new(
        mutation:    mutation,
        test_result: test_result
      )
    end

  private

    # Kill mutation under isolation with integration
    #
    # @param [Isolation] isolation
    # @param [Integration] integration
    #
    # @return [Result::Test]
    #
    # rubocop:disable MethodLength
    def run_mutation_tests(mutation)
      start = Time.now
      tests = selector.call(mutation.subject)

      config.isolation.call do
        mutation.insert(config.kernel)
        integration.call(tests)
      end
    rescue Isolation::Error => error
      Result::Test.new(
        output:  error.message,
        passed:  false,
        runtime: Time.now - start,
        tests:   tests
      )
    end

  end # Env
end # Mutant
