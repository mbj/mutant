module Mutant
  # Abstract base class for reporters
  class Reporter
    include Adamantium::Flat, AbstractType

    # Report object
    #
    # @param [Object] object
    #
    # @return [self]
    #
    # @api private
    #
    abstract_method :report

    # Report progress on object
    #
    # @param [Object] object
    #
    # @return [self]
    #
    # @api private
    #
    abstract_method :progress

  end # Reporter
end # Mutant
