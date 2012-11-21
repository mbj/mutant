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

      reporter.config(config)

      run
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
      subject.each do |mutation|
        next unless config.filter.match?(mutation)
        reporter.mutation(mutation)
        kill(mutation)
      end
      subject.reset
    end

    # Run killer on mutation
    #
    # @param [Mutation] mutation
    #
    # @return [undefined]
    #
    # @api private
    #
    def kill(mutation)
      killer = config.killer.new(mutation)
      reporter.killer(killer)
      if killer.fail?
        @errors << killer
      end
    end
  end
end
