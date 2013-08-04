# encoding: utf-8

module Mutant
  # Abstract base class for mutant killers
  class Killer
    include Adamantium::Flat, AbstractType
    include Equalizer.new(:strategy, :mutation, :killed?)

    # Return strategy
    #
    # @return [Strategy]
    #
    # @api private
    #
    attr_reader :strategy

    # Return mutation to kill
    #
    # @return [Mutation]
    #
    # @api private
    #
    attr_reader :mutation

    # Initialize killer object
    #
    # @param [Strategy] strategy
    # @param [Mutation] mutation
    #
    # @return [undefined]
    #
    # @api private
    #
    def initialize(strategy, mutation)
      @strategy, @mutation = strategy, mutation
      run_with_benchmark
    end

    # Test for kill failure
    #
    # @return [true]
    #   when killer succeeded
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    def success?
      mutation.success?(self)
    end
    memoize :success?

    # Test if mutant was killed
    #
    # @return [true]
    #   if mutant was killed
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    def killed?
      @killed
    end

    # Return runtime of killer
    #
    # @return [Float]
    #
    # @api private
    #
    attr_reader :runtime

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

    # Run with taking the time
    #
    # @return [undefined]
    #
    # @api private
    #
    def run_with_benchmark
      times = Benchmark.measure do
        @killed = run
      end
      @runtime = times.real
    end

    # Return subject
    #
    # @return [Subject]
    #
    # @api private
    #
    def subject
      mutation.subject
    end

    # Run killer
    #
    # @return [true]
    #   when mutant was killed
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    abstract_method :run

  end # Killer
end # Mutant
