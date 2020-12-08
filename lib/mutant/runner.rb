# frozen_string_literal: true

module Mutant
  # Runner
  module Runner
    # Run against env
    #
    # @return [Either<String, Result>]
    def self.apply(env)
      reporter(env).start(env)

      Either::Right.new(run_mutation_analysis(env))
    end

    def self.run_mutation_analysis(env)
      reporter = reporter(env)

      run_driver(
        reporter,
        Parallel.async(mutation_test_config(env))
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
      world = env.world

      Parallel::Config.new(
        condition_variable: world.condition_variable,
        jobs:               env.config.jobs,
        mutex:              world.mutex,
        processor:          env.method(:kill),
        sink:               Sink.new(env),
        source:             Parallel::Source::Array.new(env.mutations),
        thread:             world.thread
      )
    end
    private_class_method :mutation_test_config

    def self.reporter(env)
      env.config.reporter
    end
    private_class_method :reporter

  end # Runner
end # Mutant
