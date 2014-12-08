module Mutant
  # Runner baseclass
  class Runner
    include Adamantium::Flat, Concord.new(:env), Procto.call(:result)

    # Status of the runner execution
    class Status
      include Adamantium, Anima::Update, Anima.new(
        :env_result,
        :active_jobs,
        :done
      )
    end # Status

    # Job to push to workers
    class Job
      include Adamantium::Flat, Anima.new(:index, :mutation)
    end # Job

    # Job result object received from workers
    class JobResult
      include Adamantium::Flat, Anima.new(:job, :result)
    end

    # Initialize object
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(*)
      super

      reporter.start(env)
      config.integration.setup

      @master = config.actor_env.new_mailbox.bind(Master.call(env))

      status = nil

      loop do
        status = current_status
        break if status.done
        reporter.progress(status)
        Kernel.sleep(reporter.delay)
      end

      reporter.progress(status)

      @master.call(:stop)

      @result = status.env_result

      reporter.report(@result)
    end

    # Return result
    #
    # @return [Result::Env]
    #
    # @api private
    #
    attr_reader :result

  private

    # Return reporter
    #
    # @return [Reporter]
    #
    # @api private
    #
    def reporter
      env.config.reporter
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

    # Return current status
    #
    # @return [Status]
    #
    # @api private
    #
    def current_status
      @master.call(:status)
    end

  end # Runner
end # Mutant
