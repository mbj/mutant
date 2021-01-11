# frozen_string_literal: true

module Mutant
  # Lightweight concurrency variables
  #
  # These are inspired by Haskells MVar and IVar types.
  class Variable
    EMPTY = Class.new do
      const_set(:INSPECT, 'Variable::EMPTY')
    end.new.freeze

    TIMEOUT = Class.new do
      const_set(:INSPECT, 'Variable::TIMEOUT')
    end.new.freeze

    # Result of operation that may time out
    class Result
      include Equalizer.new(:value)
      attr_reader :value

      # Initialize result
      #
      # @return [undefined]
      def initialize(value)
        @value = value
        freeze
      end

      # Test if take resulted in a timeout
      #
      # @return [Boolean]
      #
      # @api private
      def timeout?
        instance_of?(Timeout)
      end

      # Instance returned on timeouts
      class Timeout < self
        INSTANCE = new(nil)

        # Construct new object
        #
        # @return [Timeout]
        def self.new
          INSTANCE
        end
      end # Timeout

      # Instance returned without timeouts
      class Value < self
      end # Value
    end # Result

    private_constant(*constants(false))

    module Timer
      # Monotonic elapsed time of block execution
      #
      # @return [Float]
      def self.elapsed
        start = now
        yield
        now - start
      end

      # The now monotonic time
      #
      # @return [Float]
      def self.now
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
      private_class_method :now
    end # Timer

    # Initialize object
    #
    # @param [Object] value
    #   the initial value
    #
    # @return [undefined]
    def initialize(condition_variable:, mutex:, value: EMPTY)
      @full  = condition_variable.new
      @mutex = mutex.new
      @value = value
    end

    # Take value, block on empty
    #
    # @return [Object]
    def take
      synchronize do
        wait_full
        perform_take
      end
    end

    # Take value, with timeout
    #
    # @param [Float] Timeout
    #
    # @return [Result::Timeout]
    #   in case take resulted in a timeout
    #
    # @return [Result::Value]
    #   in case take resulted in a value
    def take_timeout(timeout)
      synchronize do
        if wait_timeout(@full, timeout, &method(:full?))
          Result::Timeout.new
        else
          Result::Value.new(perform_take)
        end
      end
    end

    # Read value, block on empty
    #
    # @return [Object]
    #   the variable value
    def read
      synchronize do
        wait_full
        @value
      end
    end

    # Try put value into the variable, non blocking
    #
    # @param [Object] value
    #
    # @return [self]
    def try_put(value)
      synchronize do
        perform_put(value) if empty?
      end

      self
    end

    # Execute block with value, blocking
    #
    # @yield [Object]
    #
    # @return [Object]
    #   the blocks return value
    def with
      synchronize do
        wait_full
        yield @value
      end
    end

  private

    # Perform the put
    #
    # @param [Object] value
    def perform_put(value)
      (@value = value).tap { @full.signal }
    end

    # Execute block under mutex
    #
    # @return [self]
    def synchronize(&block)
      @mutex.synchronize(&block)
    end

    # Wait for block predicate
    #
    # @param [ConditionVariable] event
    #
    # @return [undefined]
    def wait(event)
      event.wait(@mutex) until yield
    end

    # Wait with timeout for block predicate
    #
    # @param [ConditionVariable] event
    #
    # @return [Boolean]
    #   if wait was terminated due a timeout
    #
    # @return [undefined]
    #   otherwise
    def wait_timeout(event, timeout)
      loop do
        break true if timeout <= 0
        break if yield
        timeout -= Timer.elapsed { event.wait(@mutex, timeout) }
      end
    end

    # Wait till mvar is full
    #
    # @return [undefined]
    def wait_full
      wait(@full, &method(:full?))
    end

    # Test if state is full
    #
    # @return [Boolean]
    def full?
      !empty?
    end

    # Test if state is empty
    #
    # @return [Boolean]
    def empty?
      @value.equal?(EMPTY)
    end

    # Shared variable that can be written at most once
    #
    # ignore :reek:InstanceVariableAssumption
    class IVar < self

      # Exception raised on ivar errors
      class Error < RuntimeError; end

      # Put value, raises if already full
      #
      # @param [Object] value
      #
      # @return [self]
      #
      # @raise Error
      #   if already full
      def put(value)
        synchronize do
          fail Error, 'is immutable' if full?
          perform_put(value)
        end

        self
      end

      # Populate and return value, use block to compute value if empty
      #
      # The block is guaranteed to be executed at max once.
      #
      # Subsequent reads are guaranteed to return the block value.
      #
      # @return [Object]
      def populate_with
        return @value if full?

        synchronize do
          perform_put(yield) if empty?
        end

        @value
      end

    private

      # Perform take operation
      #
      # @return [Object]
      def perform_take
        @value
      end
    end # IVar

    # Shared variable that can be written multiple times
    #
    # ignore :reek:InstanceVariableAssumption
    class MVar < self

      # Initialize object
      #
      # @param [Object] value
      #   the initial value
      #
      # @return [undefined]
      def initialize(condition_variable:, mutex:, value: EMPTY)
        super
        @empty = condition_variable.new
      end

      # Put value, block on full
      #
      # @param [Object] value
      #
      # @return [self]
      def put(value)
        synchronize do
          wait(@empty, &method(:empty?))
          perform_put(value)
        end

        self
      end

      # Modify value, blocks if empty
      #
      # @return [Object]
      def modify
        synchronize do
          wait_full
          perform_put(yield(@value))
        end
      end

    private

      # Empty the variable
      #
      # @return [Object]
      def perform_take
        @value.tap do
          @value = EMPTY
          @empty.signal
        end
      end
    end # MVar
  end # Variable
end # Mutant
