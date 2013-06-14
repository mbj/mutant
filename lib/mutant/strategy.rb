module Mutant

  # Abstract base class for killing strategies
  class Strategy
    include AbstractType, Adamantium::Flat, Equalizer.new

    # Return config
    #
    # @return [Config]
    #
    # @api private
    #
    attr_reader :config

    # Initialize object
    #
    # @param [Config] config
    #
    # @return [undefined
    #
    # @api private
    #
    def initialize(config)
      @config = config
    end

    # Perform setup
    #
    # @return [self]
    #
    # @api private
    #
    def setup
      self
    end

    # Perform teardown
    #
    # @return [self]
    #
    # @api private
    #
    def teardown
      self
    end

    # Kill mutation
    #
    # @param [Mutation] mutation
    #
    # @return [Killer]
    #
    # @api private
    #
    def kill(mutation)
      killer.new(self, mutation)
    end

    # Return killer
    #
    # @return [Class:Killer]
    #
    # @api private
    #
    def killer
      self.class::KILLER
    end

  end # Strategy
end # Mutant
