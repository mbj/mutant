module Mutant
  # Abstract base class for reporters
  class Reporter
    include AbstractType

    # Write warning message
    #
    # @param [String] message
    #
    # @return [self]
    #
    # @api private
    abstract_method :warn

    # Report start
    #
    # @param [Env] env
    #
    # @return [self]
    #
    # @api private
    abstract_method :start

    # Report collector state
    #
    # @param [Runner::Collector] collector
    #
    # @return [self]
    #
    # @api private
    abstract_method :report

    # Report progress on object
    #
    # @param [Object] object
    #
    # @return [self]
    #
    # @api private
    abstract_method :progress

    # The reporter delay
    #
    # @return [Float]
    #
    # @api private
    abstract_method :delay

  end # Reporter
end # Mutant
