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
      status = nil
      sleep  = env.config.kernel.method(:sleep)

      loop do
        status = driver.status
        reporter.progress(status)
        break if status.done
        sleep.call(reporter.delay)
      end

      driver.stop

      status.payload
    end

    # Configuration for parallel execution engine
    #
    # @return [Parallel::Config]
    def mutation_test_config
      Parallel::Config.new(
        env:       env.actor_env,
        jobs:      config.jobs,
        processor: env.method(:kill),
        sink:      Sink.new(env),
        source:    Parallel::Source::Array.new(env.mutations)
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
