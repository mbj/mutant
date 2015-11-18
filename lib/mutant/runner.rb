module Mutant
  # Runner baseclass
  class Runner
    include Adamantium::Flat, Concord.new(:env), Procto.call(:result)

    # Initialize object
    #
    # @return [undefined]
    #
    # @api private
    def initialize(*)
      super

      reporter.start(env)

      run_mutation_analysis
    end

    # Final result
    #
    # @return [Result::Env]
    #
    # @api private
    attr_reader :result

  private

    # Run mutation analysis
    #
    # @return [undefined]
    #
    # @api private
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
    #
    # @api private
    def run_driver(driver)
      status = nil

      loop do
        status = driver.status
        reporter.progress(status)
        break if status.done
        Kernel.sleep(reporter.delay)
      end

      driver.stop

      status.payload
    end

    # Configuration for parallel execution engine
    #
    # @return [Parallel::Config]
    #
    # @api private
    def mutation_test_config
      Parallel::Config.new(
        env:       env.actor_env,
        jobs:      config.jobs,
        source:    Parallel::Source::Array.new(env.mutations),
        sink:      Sink.new(env),
        processor: env.method(:kill)
      )
    end

    # Reporter to use
    #
    # @return [Reporter]
    #
    # @api private
    def reporter
      env.config.reporter
    end

    # Config for this mutant execution
    #
    # @return [Config]
    #
    # @api private
    def config
      env.config
    end

  end # Runner
end # Mutant
