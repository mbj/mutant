module Mutant
  # Abstract base class for mutant killers
  class Killer
    include Adamantium::Flat, AbstractType
    
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

    # Return strategy
    #
    # @return [Strategy]
    #
    # @api private
    #
    attr_reader :strategy

    # Return name of killer
    #
    # @return [String]
    #
    # @api private
    #
    def self.type
      self::TYPE
    end

    # Return identification
    #
    # @return [String]
    #
    # @api private
    # 
    def identification
      "#{type}:#{mutation.identification}".freeze
    end
    memoize :identification

    # Return mae of killer
    #
    # @return [String]
    #
    # @api private
    #
    def type
      self.class.type
    end

  private

    # Return mutation to kill
    #
    # @return [Mutation]
    #
    # @api private
    #
    attr_reader :mutation

    # Initialize killer object
    #
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

    # Run with taking the time
    #
    # @return [undefined]
    #
    # @api private
    #
    def run_with_benchmark
      mutation.insert
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
