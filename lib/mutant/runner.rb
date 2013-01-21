module Mutant
  # Runner that allows to mutate an entire project
  class Runner
    include Adamantium::Flat, Equalizer.new(:config)
    extend MethodObject

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
      !reporter.empty? && reporter.errors?
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
      @config = config
      run
    end

    # Return strategy
    #
    # @return [Strategy]
    #
    # @api private
    #
    def strategy
      config.strategy
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
      reporter.print_config
      util = strategy
      util.setup
      config.matcher.each do |subject|
        reporter.subject(subject)
        run_subject(subject)
      end
      util.teardown
      reporter.print_stats
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
      return unless test_noop(subject)
      subject.each do |mutation|
        next unless config.filter.match?(mutation)
        reporter.mutation(mutation)
        kill(mutation)
      end
    end

    # Test noop mutation
    #
    # @return [true]
    #   if noop mutation is alive
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    def test_noop(subject)
      noop = subject.noop
      unless kill(noop)
        reporter.noop(noop)
        return false
      end
      true
    end

    # Run killer on mutation
    #
    # @param [Mutation] mutation
    #
    # @return [true]
    #   if killer was successful
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    def kill(mutation)
      killer = killer(mutation)
      reporter.report_killer(killer)
      killer.success?
    end

    # Return killer for mutation
    #
    # @return [Killer]
    #
    # @api private
    #
    def killer(mutation)
      strategy.kill(mutation)
    end
  end
end
