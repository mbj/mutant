# frozen_string_literal: true

module Mutant
  # Runner baseclass
  class Runner
    include Adamantium::Flat, Concord.new(:env), Procto.call(:result)

    # Initialize object
    #
    # @return [undefined]
    def initialize(*)
      super

      reporter.start(env)

      run_mutation_analysis
    end

    # Final result
    #
    # @return [Result::Env]
    attr_reader :result

  private

    # Run mutation analysis
    #
    # @return [undefined]
    def run_mutation_analysis
      @result = run_driver(Parallel.async(mutation_test_config))
      reporter.report(result)
    end

    # Run driver
    #
    # @param [Driver] driver
    #
    # @return [Object]
    #   the last returned status payload
    def run_driver(driver)
      loop do
        status = driver.wait_timeout(reporter.delay)
        break status.payload if status.done?
        reporter.progress(status)
      end
    end

    # Configuration for parallel execution engine
    #
    # @return [Object]
    def mutation_test_config
      Parallel::Config.new(
        condition_variable: config.condition_variable,
        jobs:               config.jobs,
        mutex:              config.mutex,
        processor:          env.method(:kill),
        sink:               Sink.new(env),
        source:             Parallel::Source::Array.new(env.mutations),
        thread:             config.thread
      )
    end

    # Reporter to use
    #
    # @return [Reporter]
    def reporter
      env.config.reporter
    end

    # Config for this mutant execution
    #
    # @return [Config]
    def config
      env.config
    end

  end # Runner
end # Mutant
