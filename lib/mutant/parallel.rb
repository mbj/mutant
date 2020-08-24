# frozen_string_literal: true

module Mutant
  # Parallel execution engine of arbitrary payloads
  module Parallel

    # Run async computation returning driver
    #
    # @param [Config] config
    #
    # @return [Driver]
    def self.async(config)
      shared = {
        var_active_jobs: shared(Variable::IVar, config, value: Set.new),
        var_final:       shared(Variable::IVar, config),
        var_sink:        shared(Variable::IVar, config, value: config.sink)
      }

      Driver.new(
        threads: threads(config, worker(config, **shared)),
        **shared
      )
    end

    # The worker
    #
    # @param [Config] config
    #
    # @return [Worker]
    def self.worker(config, **shared)
      Worker.new(
        processor:   config.processor,
        var_running: shared(Variable::MVar, config, value: config.jobs),
        var_source:  shared(Variable::IVar, config, value: config.source),
        **shared
      )
    end

    def self.threads(config, worker)
      Array.new(config.jobs) { config.thread.new(&worker.method(:call)) }
    end
    private_class_method :threads

    # ignore :reek:LongParameterList
    def self.shared(klass, config, **attributes)
      klass.new(
        condition_variable: config.condition_variable,
        mutex:              config.mutex,
        **attributes
      )
    end
    private_class_method :shared

    # Job result sink
    class Sink
      include AbstractType

      # Process job result
      #
      # @param [Object]
      #
      # @return [self]
      abstract_method :result

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
      include Adamantium::Flat, Anima.new(
        :condition_variable,
        :jobs,
        :mutex,
        :processor,
        :sink,
        :source,
        :thread
      )
    end # Config

    # Parallel execution status
    class Status
      include Adamantium::Flat, Anima.new(
        :active_jobs,
        :done,
        :payload
      )

      alias_method :done?, :done
    end # Status

  end # Parallel
end # Mutant
