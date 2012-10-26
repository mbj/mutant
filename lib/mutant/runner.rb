module Mutant
  # Runner that allows to mutate an entire project
  class Runner
    include Adamantium, Anima
    extend MethodObject

    attribute :matcher
    attribute :killer
    attribute :reporter
    attribute :mutation_filter

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

  private

    # Initialize object
    #
    # @param [Hash] attributes
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(attributes)
      attributes[:reporter]        ||= Reporter::Null
      attributes[:mutation_filter] ||= Mutation::Filter::ALL

      super(attributes)

      @errors = []

      run
    end

    # Run mutation killers on subjects
    #
    # @return [undefined]
    #
    # @api private
    #
    def run
      matcher.each do |subject|
        reporter.subject(subject)
        #run_subject(subject)
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
        reporter.mutation(mutation)
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
