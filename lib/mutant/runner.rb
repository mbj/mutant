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
      @killer  = Helper.extract_option(options, :killer)
      @pattern = Helper.extract_option(options, :pattern) 
      @reporter = options.fetch(:reporter, Reporter::Null)
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
      @subjects = subjects.each do |subject|
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

    # Return candiate matcher enumerator
    #
    # @return [Enumerable<Class<Matcher>>]
    #
    # @api private
    #
    def candidate_matchers
      [Matcher::Method::Singleton, Matcher::Method::Instance].each
    end

    # Return candidats enumerator
    #
    # @return [Enumerable<Object>]
    #
    # @api private
    #
    def candidates
      return to_enum(__method__) unless block_given?
      ObjectSpace.each_object(Module) do |candidate|
        yield candidate if @pattern =~ candidate.name and [::Module,::Class].include?(candidate.class)
      end
    end

    # Return matcher enumerator
    #
    # @return [Enumerable<Matcher>]
    #
    # @api private
    #
    def matchers(&block)
      return to_enum(__method__) unless block_given?
      candidate_matchers.each do |candidate_matcher|
        candidates.each do |candidate|
          candidate_matcher.each(candidate,&block)
        end
      end
    end

    # Return subjects enumerator
    #
    # @return [Enumerable<Subject>]
    #
    # @api private
    #
    def subjects(&block)
      return to_enum(__method__) unless block_given?
      matchers.each do |matcher|
        matcher.each(&block)
      end
    end
  end
end
