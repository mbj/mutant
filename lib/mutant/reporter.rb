module Mutant
  # Abstract base class for reporters
  class Reporter
    include AbstractType

    # Write warning message
    #
    # @param [String] message
    #
    # @return [self]
    abstract_method :warn

    # Report start
    #
    # @param [Env] env
    #
    # @return [self]
    abstract_method :start

    # Report collector state
    #
    # @param [Runner::Collector] collector
    #
    # @return [self]
    abstract_method :report

    # Report progress on object
    #
    # @param [Object] object
    #
    # @return [self]
    abstract_method :progress

    # The reporter delay
    #
    # @return [Float]
    abstract_method :delay

  end # Reporter
end # Mutant
