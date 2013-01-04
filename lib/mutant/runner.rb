module Mutant
  # Runner that allows to mutate an entire project
  class Runner
    include Adamantium::Flat
    extend MethodObject

    # Return killers with errors
    #
    # @return [Enumerable<Killer>]
    #
    # @api private
    #
    attr_reader :errors

    # Test for failure
    #
    # @return [true]
    #   returns true when there are left mutations
    #
    # @return [false]
    #   returns false othewise
    #
    # @api private
    #
    def fail?
      !errors.empty?
    end

    # Return config
    #
    # @return [Mutant::Config]
    #
    # @api private
    #
    attr_reader :config

  private

    # Initialize object
    #
    # @param [Config] config
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(config)
      @config, @errors = config, []

      util_reporter = reporter
      util_reporter.config(config)
      run
      util_reporter.errors(@errors)
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

    # Run mutation killers on subjects
    #
    # @return [undefined]
    #
    # @api private
    #
    def run
      config.matcher.each do |subject|
        reporter.subject(subject)
        run_subject(subject)
      end
    end

    # Run mutation killers on subject
    #
    # @param [Subject] subject
    #
    # @return [undefined]
    #
    # @api private
    #
    def run_subject(subject)
      return unless noop(subject)
      subject.each do |mutation|
        next unless config.filter.match?(mutation)
        reporter.mutation(mutation)
        kill(mutation)
      end
    end

    # Test for noop mutation
    #
    # @param [Subject] subject
    #
    # @return [true]
    #   if noop mutation is okay
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    def noop(subject)
      killer = killer(subject.noop)
      reporter.noop(killer)
      unless killer.fail?
        @errors << killer
        return false
      end

      true
    end

    # Run killer on mutation
    #
    # @param [Mutation] mutation
    #
    # @return [true]
    #   if killer was unsuccessful
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    def kill(mutation)
      killer = killer(mutation)
      reporter.killer(killer)

      if killer.fail?
        @errors << killer
      end
    end

    # Return killer for mutation
    #
    # @return [Killer]
    #
    # @api private
    #
    def killer(mutation)
      config.strategy.kill(mutation)
    end
  end
end
