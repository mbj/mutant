module Mutant
  # Runner that allows to mutate an entire project
  class Runner
    include Immutable
    extend MethodObject

    attr_reader :errors

    def fail?
      !errors.empty?
    end

  private

    attr_reader :reporter
    private :reporter

    def initialize(options)
      @killer = options.fetch(:killer) do
        raise ArgumentError, 'Missing :killer in options'
      end

      @pattern = options.fetch(:pattern) do
        raise ArgumentError, 'Missing :pattern in options'
      end

      @reporter = options.fetch(:reporter, Reporter::Null)

      @errors = []

      run
    end

    def run
      @subjects = subjects.each do |subject|
        reporter.subject(subject)
        run_subject(subject)
      end
    end

    def run_subject(subject)
      subject.each do |mutation|
        reporter.mutation(mutation)
        kill(mutation)
      end
      subject.reset
    end

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
        yield candidate if @pattern =~ candidate.name
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
