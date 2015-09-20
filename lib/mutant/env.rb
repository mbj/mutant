module Mutant
  # Abstract base class for mutant environments
  class Env
    include Adamantium::Flat, Anima.new(
      :actor_env,
      :cache,
      :config,
      :integration,
      :expression_parser,
      :isolation,
      :selector,
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
    #
    # @api private
    def run_mutation_tests(mutation)
      start = Time.now
      tests = selector.call(mutation.subject)

      isolation.call do
        mutation.insert
        integration.call(tests)
      end
    rescue Isolation::Error => error
      Result::Test.new(
        tests:   tests,
        output:  error.message,
        runtime: Time.now - start,
        passed:  false
      )
    end

  end # Env
end # Mutant
