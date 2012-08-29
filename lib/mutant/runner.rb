module Mutant
  # Runner that allows to mutate an entire project
  class Runner
    include Immutable
    extend MethodObject

    # Return killers with errors
    #
    # @return [Enumerable<Killer>]
    #
    # @api private
    #
    def errors; @errors; end

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

  private

    # Return reporter
    #
    # @return [Reporter]
    #
    # @api private
    #
    def reporter; @reporter; end

    # Initialize runner object
    #
    # @param [Hash] options
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(options)
      @killer          = Helper.extract_option(options, :killer)
      @matcher         = Helper.extract_option(options, :matcher) 
      @reporter        = options.fetch(:reporter,        Reporter::Null)
      @mutation_filter = options.fetch(:mutation_filter, Mutation::Filter::ALL)
      @errors = []

      run
    end

    # Return subject enumerator
    #
    # @return [Enumerator<Subject>]
    #
    # @api private
    #
    def subjects
      @matcher.each
    end

    # Run mutation killers on subjects
    #
    # @return [undefined]
    #
    # @api private
    #
    def run
      subjects.each do |subject|
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
        next unless @mutation_filter.match?(mutation)
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
      killer = @killer.run(mutation)
      reporter.killer(killer)
      if killer.fail?
        @errors << killer
      end
    end
  end
end

    # Return candiate matcher enumerator
    #
    # @return [Enumerable<Class<Matcher>>]
    #
    # @api private
    #
    def candidate_matchers
      [Matcher::Method::Singleton, Matcher::Method::Instance].each
    end
