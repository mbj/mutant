# frozen_string_literal: true

module Mutant
  class Mutation
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

        env
          .record(:analysis) { run_driver(reporter, async_driver(env)) }
          .tap { |result| env.record(:report) { reporter.report(result) } }
      end
      private_class_method :run_mutation_analysis

      def self.async_driver(env)
        Parallel.async(world: env.world, config: mutation_test_config(env))
      end
      private_class_method :async_driver

      def self.run_driver(reporter, driver)
        Signal.trap('INT') do
          driver.stop
        end

        loop do
          status = driver.wait_timeout(reporter.delay)
          break status.payload if status.done?
          reporter.progress(status)
        end
      end
      private_class_method :run_driver

      def self.mutation_test_config(env)
        Parallel::Config.new(
          block:            env.method(:cover_index),
          jobs:             env.config.jobs,
          on_process_start: env.method(:emit_mutation_worker_process_start),
          process_name:     'mutant-worker-process',
          sink:             Sink.new(env: env),
          source:           Parallel::Source::Array.new(jobs: env.mutations.each_index.to_a),
          timeout:          nil,
          thread_name:      'mutant-worker-thread'
        )
      end
      private_class_method :mutation_test_config

      def self.reporter(env)
        env.config.reporter
      end
      private_class_method :reporter

    end # Runner
  end # Mutation
end # Mutant
