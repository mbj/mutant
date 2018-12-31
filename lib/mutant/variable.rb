# frozen_string_literal: true

module Mutant
  # Lightweight shared variables
  #
  # ignore :reek:TooManyMethods
  class Variable
    EMPTY = Class.new do
      const_set(:INSPECT, 'Mutant::Variable::EMPTY')
    end.new.freeze

    TIMEOUT = Class.new do
      const_set(:INSPECT, 'Mutant::Variable::TIMEOUT')
    end.new.freeze

    # Result of operation that may time out
    class Result
      include AbstractType, Adamantium::Flat

      # Test if take resulted in a timeout
      #
      # @return [Boolean]
      #
      # @api private
      def timeout?
        instance_of?(Timeout)
      end

      abstract_method :value

      # Instance returned on timeouts
      class Timeout < self
        include Equalizer.new

        INSTANCE = new

        # Construct new object
        #
        # @return [Timeout]
        def self.new
          INSTANCE
        end
      end # Timeout

      # Instance returned without timeouts
      class Value < self
        include Concord::Public.new(:value)
      end # Value
    end # Result

    private_constant(*constants(false))

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

    # Take value from mvar, block on empty
    #
    # @return [Object]
    def take
      synchronize do
        wait_full
        perform_take
      end
    end

    # Take value from mvar, with timeout
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

    # Read value from variable
    #
    # @return [Object]
    #   the contents of the mvar
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

      # Put valie into the mvar, raises if already full
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

      # Put value into mvar, block on full
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

      # Modify mvar
      #
      # @return [Object]
      def modify
        synchronize do
          wait_full
          perform_put(yield(@value))
        end
      end

    private

      # Empty the mvar
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
