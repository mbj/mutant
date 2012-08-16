module Mutant
  # Abstract runner for mutant killers
  class Killer
    include Immutable, Abstract
    extend MethodObject

    # Check if mutant was killed
    #
    # @return [true]
    #   returns true when mutant was killed
    #
    # @return [false]
    #   returns false otherwise
    #
    # @api private
    #
    def fail?
      !@killed
    end

    # Return runtime of killer
    #
    # @return [Float]
    #
    # @api private
    #
    attr_reader :runtime

    # Return original source
    #
    # @return [String]
    #
    def original_source
      mutation.original_source
    end

    # Return mutated source
    #
    # @return [String]
    #
    def mutation_source
      mutation.source
    end

  private

    attr_reader :mutation
    private :mutation

    # Initialize runner and run the test
    #
    # @param [Mutation] mutation
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(mutation)
      @mutation = mutation
      @mutation.insert
      start_time = Time.now
      @killed = run
      end_time = Time.now
      @runtime = end_time - start_time 
    end

    # Run test
    #
    # @return [true]
    #   returns true when mutant was killed
    #
    # @return [false]
    #   returns false otherwise
    #
    # @api private
    #
    abstract_method :run
  end
end
