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
  end # Timer
end # Mutant
