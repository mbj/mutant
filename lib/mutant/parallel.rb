module Mutant
  # Parallel execution engine of arbitrary payloads
  module Parallel

    # Driver for parallelized execution
    class Driver
      include Concord.new(:binding)

      # Scheduler status
      #
      # @return [Object]
      def status
        binding.call(__method__)
      end

      # Stop master gracefully
      #
      # @return [self]
      def stop
        binding.call(__method__)
        self
      end
    end # Driver

    # Run async computation returning driver
    #
    # @return [Driver]
    def self.async(config)
      Driver.new(config.env.new_mailbox.bind(Master.call(config)))
    end

    # Job result sink
    class Sink
      include AbstractType

      # Process job result
      #
      # @param [Object]
      #
      # @return [self]
      abstract_method :result

      # Sink status
      #
      # @return [Object]
      abstract_method :status

      # Test if processing should stop
      #
      # @return [Boolean]
      abstract_method :stop?
    end # Sink

    # Job to push to workers
    class Job
      include Adamantium::Flat, Anima.new(
        :index,
        :payload
      )
    end # Job

    # Job result object received from workers
    class JobResult
      include Adamantium::Flat, Anima.new(
        :job,
        :payload
      )
    end # JobResult

    # Parallel run configuration
    class Config
      include Adamantium::Flat, Anima.new(
        :env,
        :jobs,
        :processor,
        :sink,
        :source
      )
    end # Config

    # Parallel execution status
    class Status
      include Adamantium::Flat, Anima.new(
        :active_jobs,
        :done,
        :payload
      )
    end # Status

  end # Parallel
end # Mutant
