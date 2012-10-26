module Mutant
  # Abstract runner for mutant killers
  class Killer
    include Adamantium, AbstractClass
    extend MethodObject

    # Test for kill failure
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
    # @api private
    #
    def original_source
      mutation.original_source
    end

    # Return mutated source
    #
    # @return [String]
    #
    # @api private
    #
    def mutation_source
      mutation.source
    end

  private

    # Return mutation to kill
    #
    # @return [Mutation]
    #
    # @api private
    #
    def mutation; @mutation; end

    # Initialize killer object
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
