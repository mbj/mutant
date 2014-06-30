module Mutant
  # Abstract base class for mutant environments
  class Env
    include AbstractType, Adamantium

    # Return config
    #
    # @return [Config]
    #
    # @api private
    #
    abstract_method :config

    # Return cache
    #
    # @return [Cache]
    #
    # @api private
    #
    abstract_method :cache

    # Return reporter
    #
    # @return [Reporter]
    #
    # @api private
    #
    abstract_method :reporter

    # Print warning message
    #
    # @param [String]
    #
    # @return [self]
    #
    # @api private
    #
    def warn(message)
      reporter.warn(message)
      self
    end

    # Boot environment used for matching
    class Boot < self
      include Concord::Public.new(:reporter, :cache)
    end # Boot

  end # ENV
end # Mutant
