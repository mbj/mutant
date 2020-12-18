# frozen_string_literal: true

module Mutant
  # Runner
  module Runner
    # Run against env
    #
    # @return [Either<String, Result>]
    def self.call(env)
      reporter(env).start(env)

      Either::Right.new(run_mutation_analysis(env))
    end

    def self.run_mutation_analysis(env)
      reporter = reporter(env)

      run_driver(
        reporter,
        Parallel.async(env.world, mutation_test_config(env))
      ).tap do |result|
        reporter.report(result)
      end
    end
    private_class_method :run_mutation_analysis

    def self.run_driver(reporter, driver)
      loop do
        status = driver.wait_timeout(reporter.delay)
        break status.payload if status.done?
        reporter.progress(status)
      end
    end
    private_class_method :run_driver

    def self.mutation_test_config(env)
      Parallel::Config.new(
        block:        env.method(:cover_index),
        jobs:         env.config.jobs,
        process_name: 'mutant-worker-process',
        sink:         Sink.new(env),
        source:       Parallel::Source::Array.new(env.mutations.each_index.to_a),
        thread_name:  'mutant-worker-thread'
      )
    end
    private_class_method :mutation_test_config

    def self.reporter(env)
      env.config.reporter
    end
    private_class_method :reporter

  end # Runner
end # Mutant
