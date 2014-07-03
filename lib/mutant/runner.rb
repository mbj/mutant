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

      start = Time.now

      @result = Result::Env.new(
        env: env,
        subject_results: visit_collection(env.subjects, &method(:run_subject)),
        runtime: Time.now - start
      ).tap do |report|
        config.reporter.report(report)
      end
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
      Result::Subject.new(
        subject:          subject,
        mutation_results: visit_collection(subject.mutations, &method(:run_mutation)),
        runtime:          nil
      )
    end

    # Run mutation
    #
    # @return [Report::Mutation]
    #
    # @api private
    #
    def run_mutation(mutation)
      start = Time.now
      test_results = mutation.subject.tests.each_with_object([]) do |test, results|
        results << result = run_mutation_test(mutation, test).tap(&method(:progress))
        break results if mutation.killed_by?(result)
      end

      Result::Mutation.new(
        mutation:     mutation,
        runtime:      Time.now - start,
        test_results: test_results
      )
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
      results = []

      collection.each do |item|
        progress(item)
        start = Time.now
        results << result = yield(item).update(runtime: Time.now - start).tap(&method(:progress))
        break if @stop ||= config.fail_fast? && result.fail?
      end

      results
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
      Isolation.call do
        mutation.insert
        test.run
      end.update(test: test, mutation: mutation)
    rescue Isolation::Error
      Result::Test.new(
        test:   test,
        output: exception.message,
        passed: false
      )
    end

  end # Runner
end # Mutant
