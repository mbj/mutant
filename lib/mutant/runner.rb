module Mutant
  # Runner baseclass
  class Runner
    include Adamantium, Concord.new(:env), Procto.call(:result)

    # Initialize object
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(env)
      super

      @stop = false

      config.integration.setup

      progress(env)

      @result = Result::Env.compute do
        {
          env: env,
          subject_results: visit_collection(env.subjects, &method(:run_subject))
        }
      end

      config.reporter.report(result)
    end

    # Return result
    #
    # @return [Result::Env]
    #
    # @api private
    #
    attr_reader :result

  private

    # Run subject
    #
    # @return [Report::Subject]
    #
    # @api private
    #
    def run_subject(subject)
      Result::Subject.compute do
        {
          subject:          subject,
          mutation_results: visit_collection(subject.mutations, &method(:run_mutation))
        }
      end
    end

    # Run mutation
    #
    # @param [Mutation]
    #
    # @return [Report::Mutation]
    #
    # @api private
    #
    def run_mutation(mutation)
      Result::Mutation.compute do
        {
          mutation:     mutation,
          test_results: kill_mutation(mutation)
        }
      end
    end

    # Kill mutation
    #
    # @param [Mutation] mutation
    #
    # @return [Array<Result::Test>]
    #
    # @api private
    #
    def kill_mutation(mutation)
      mutation.subject.tests.each_with_object([]) do |test, results|
        results << result = run_mutation_test(mutation, test).tap(&method(:progress))
        return results if mutation.killed_by?(result)
      end
    end

    # Return config
    #
    # @return [Config]
    #
    # @api private
    #
    def config
      env.config
    end

    # Visit collection
    #
    # @return [Array<Result>]
    #
    # @api private
    #
    def visit_collection(collection)
      collection.each_with_object([]) do |item, results|
        progress(item)
        start = Time.now
        results << result = yield(item).update(runtime: Time.now - start).tap(&method(:progress))
        return results if @stop ||= config.fail_fast? && result.fail?
      end
    end

    # Report progress
    #
    # @param [Object] object
    #
    # @return [undefined]
    #
    # @api private
    #
    def progress(object)
      config.reporter.progress(object)
    end

    # Return test result
    #
    # @return [Report::Test]
    #
    # @api private
    #
    def run_mutation_test(mutation, test)
      time = Time.now
      config.isolation.call do
        mutation.insert
        test.run
      end.update(test: test, mutation: mutation)
    rescue Isolation::Error => exception
      Result::Test.new(
        test:     test,
        mutation: mutation,
        runtime:  Time.now - time,
        output:   exception.message,
        passed:   false
      )
    end

  end # Runner
end # Mutant
