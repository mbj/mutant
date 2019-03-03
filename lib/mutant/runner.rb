# frozen_string_literal: true

module Mutant
  # Runner
  module Runner
    # Run against env
    #
    # @return [Either<String, Result>]
    def self.apply(env)
      reporter(env).start(env)

      run_tracing(env).fmap do |env|
        run_mutation_analysis(env)
      end
    end

    # Run mutation analysis
    #
    # @param [Env] env
    #
    # @return [undefined]
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

    # Run tracing
    def self.run_tracing(env)
      integration = env.integration
      tests       = integration.all_tests

      subject_paths = env.subjects.map(&:source_path).map(&:to_s).to_set
      paths         = subject_paths + tests.map(&:path)

      result = env.config.isolation.call do
        LineTrace.call(->(trace) { paths.include?(trace.path) }) do
          integration.call(tests)
        end
      end

      if result.success?
        test_result, traces = result.value

        if test_result.passed
          trace_selector(env, traces)
        else
          Either::Left.new('Trace tests did not pass! %s' % test_result.output)
        end
      else
        Either::Left.new(trace_failure(result))
      end
    end

    # Create trace selector
    #
    # @param [Env] env
    # @param [Array<String>] traces
    #
    # @return [Either<String, Env>]
    def self.trace_selector(env, traces)
      all_tests = env.integration.all_tests

      trace_tests = {}
      test_traces = {}

      all_tests.each do |test|
        (trace_tests[test.trace_location] ||= Set.new) << test
      end

      current_traces = Set.new

      traces.each do |trace|
        tests = trace_tests[trace]

        if tests
          current_traces = tests.map do |test|
            test_traces[test.id] ||= Set.new
          end
        end

        current_traces.each { |test_trace| test_trace << trace }
      end

      missing = all_tests.count { |test| !test_traces.key?(test.id) }

      if missing.zero?
        Either::Right.new(
          env.with(
            selector: Selector::Intersection.new(
              [
                env.selector,
                Selector::Trace.new(all_tests, test_traces)
              ]
            )
          )
        )
      else
        Either::Left.new("total: #{all_tests.length} missing: #{missing}, found: #{test_traces.length} tests in traces")
      end
    end
    private_class_method :trace_selector

    # Run driver
    #
    # @param [Reporter] reporter
    # @param [Driver] driver
    #
    # @return [Object]
    #   the last returned status payload
    def self.run_driver(reporter, driver)
      loop do
        status = driver.wait_timeout(reporter.delay)
        break status.payload if status.done?
        reporter.progress(status)
      end
    end
    private_class_method :run_driver

    # Configuration for parallel execution engine
    #
    # @return [Parallell::Config]
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

    # Reporter to use
    #
    # @param [Env] env
    #
    # @return [Reporter]
    def self.reporter(env)
      env.config.reporter
    end
    private_class_method :reporter

  end # Runner
end # Mutant
