module Mutant
  # Runner baseclass
  class Runner
    include Adamantium::Flat, Concord.new(:env), Procto.call(:last_result)

    # Initialize object
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(*)
      super

      config.integration.setup
      reporter.start(env)

      phases.each do |phase|
        @last_result = run(phase)
        reporter.public_send(:"#{phase}_report", @last_result)
        break unless @last_result.success?
      end
    end

    # Return result
    #
    # @return [Result::Env]
    #
    # @api private
    #
    attr_reader :last_result

  private

    # Run phase
    #
    # @param [Symbol] phase
    #
    # @return [#success?]
    #
    # @api private
    #
    def run(phase)
      __send__(:"run_#{phase}")
    end

    # Return phases
    #
    # @return [Enumerable<Symbol>]
    #
    # @api private
    #
    def phases
      phases = []
      if config.trace
        phases << :trace
      end
      phases << :kill
    end

    # Run mutation analysis
    #
    #  @return [undefined]
    #
    #  @api private
    #
    def run_kill
      run_driver(Parallel.async(mutation_test_config), &reporter.method(:kill_status))
    end

    # Run line_tracing analysis
    #
    #  @return [undefined]
    #
    #  @api private
    #
    def run_trace
      result = run_driver(Parallel.async(line_tracing_config), &reporter.method(:trace_status))
      if result.success?
        @env = env.update(
          selector: Selector::Intersection.new(config.integration, [
            Selector::Expression.new(config.integration),
            Selector::Trace.new(merge_traces(result.test_traces))
          ]).precompute(env.subjects)
        )
      end
      result
    end

    def merge_traces(test_traces)
      result = {}
      test_traces.each do |test_trace|
        test_trace.trace.each do |file, lines|
          result_lines = result[file] ||= {}
          lines.each do |line|
            tests = result_lines[line] ||= Set.new
            tests << test_trace.test
          end
        end
      end
      result
    end

    # Run driver
    #
    # @param [Driver] driver
    #
    # @return [Object]
    #   the last returned status payload
    #
    # @api private
    #
    def run_driver(driver)
      status = nil

      loop do
        status = driver.status
        yield status
        break if status.done
        Kernel.sleep(reporter.delay)
      end

      driver.stop

      status.payload
    end

    # Return line tracing config
    #
    # @return [Parallell::Config]
    #
    # @api private
    #
    def line_tracing_config
      Parallel::Config.new(
        env:       env.actor_env,
        jobs:      config.jobs,
        source:    Parallel::Source::Array.new(config.integration.all_tests),
        sink:      Sink::Trace.new(env),
        processor: env.method(:trace)
      )
    end

    # Return mutation test config
    #
    # @return [Parallell::Config]
    #
    # @api private
    #
    def mutation_test_config
      Parallel::Config.new(
        env:       env.actor_env,
        jobs:      config.jobs,
        source:    Parallel::Source::Array.new(env.mutations),
        sink:      Sink::Mutation.new(env),
        processor: env.method(:kill)
      )
    end

    # Return reporter
    #
    # @return [Reporter]
    #
    # @api private
    #
    def reporter
      config.reporter
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

  end # Runner
end # Mutant
