# frozen_string_literal: true

module Mutant
  class Timer
    include Concord.new(:process)

    # The now monotonic time
    #
    # @return [Float]
    def now
      process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    class Deadline
      include Anima.new(:timer, :allowed_time)

      def initialize(**arguments)
        super(**arguments)
        @start_at = timer.now
      end

      # Test if deadline is expired
      #
      # @return [Boolean]
      def expired?
        time_left <= 0
      end

      # Deadline status snapshot
      class Status
        include Concord::Public.new(:time_left)

        # Test if deadline is not yet expired
        def ok?
          time_left.nil? || time_left.positive?
        end
      end # Status

      # Capture a deadline status
      #
      # @return [Status]
      def status
        Status.new(time_left)
      end

      # Probe the time left
      #
      # @return [Float, nil]
      def time_left
        allowed_time - (timer.now - @start_at)
      end

      # Deadline that never expires
      class None < self
        include Concord.new

        STATUS = Status.new(nil)

        # The time left
        #
        # @return [Float, nil]
        def time_left; end

        def expired?
          false
        end
      end
    end # Deadline
  end # Timer
end # Mutant
