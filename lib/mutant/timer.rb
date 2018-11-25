# frozen_string_literal: true

module Mutant
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
  end # Timer
end # Mutant
