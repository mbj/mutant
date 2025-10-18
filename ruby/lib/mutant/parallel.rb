# frozen_string_literal: true

module Mutant
  # Parallel execution engine of arbitrary payloads
  module Parallel
    # Run async computation returning driver
    #
    # @param [World] world
    # @param [Config] config
    #
    # @return [Driver]
    def self.async(config:, world:)
      shared = shared_state(world, config)

      world.process_warmup

      workers = workers(world, config, shared)

      Driver.new(
        workers:,
        threads: threads(world, config, workers),
        **shared
      )
    end

    # rubocop:disable Metrics/MethodLength
    def self.workers(world, config, shared)
      Array.new(config.jobs) do |index|
        Worker.start(
          block:            config.block,
          index:,
          on_process_start: config.on_process_start,
          process_name:     "#{config.process_name}-#{index}",
          timeout:          config.timeout,
          world:,
          **shared
        )
      end
    end
    private_class_method :workers
    # rubocop:enable Metrics/MethodLength

    def self.shared_state(world, config)
      {
        var_active_jobs: shared(Variable::IVar, world, value: Set.new),
        var_final:       shared(Variable::IVar, world),
        var_running:     shared(Variable::MVar, world, value: config.jobs),
        var_sink:        shared(Variable::IVar, world, value: config.sink),
        var_source:      shared(Variable::IVar, world, value: config.source)
      }
    end
    private_class_method :shared_state

    def self.threads(world, config, workers)
      thread = world.thread

      workers.map do |worker|
        thread.new do
          thread.current.name = "#{config.thread_name}-#{worker.index}"
          worker.call
        end
      end
    end
    private_class_method :threads

    def self.shared(klass, world, **attributes)
      klass.new(
        condition_variable: world.condition_variable,
        mutex:              world.mutex,
        **attributes
      )
    end
    private_class_method :shared

    # Job result sink signature
    module Sink
      include AbstractType

      # Process job result
      #
      # @param [Response]
      #
      # @return [self]
      abstract_method :response

      # The sink status
      #
      # @return [Object]
      abstract_method :status

      # Test if processing should stop
      #
      # @return [Boolean]
      abstract_method :stop?
    end # Sink

    # Parallel run configuration
    class Config
      include Adamantium, Anima.new(
        :block,
        :jobs,
        :on_process_start,
        :process_name,
        :sink,
        :source,
        :thread_name,
        :timeout
      )
    end # Config

    class Response
      include Anima.new(:error, :job, :log, :result)
    end

    # Parallel execution status
    class Status
      include Adamantium, Anima.new(
        :active_jobs,
        :done,
        :payload
      )

      alias_method :done?, :done
    end # Status

  end # Parallel
end # Mutant
