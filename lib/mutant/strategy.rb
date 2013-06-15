module Mutant

  # Abstract base class for killing strategies
  class Strategy
    include AbstractType, Adamantium::Flat

    # Perform setup
    #
    # @return [self]
    #
    # @api private
    #
    def self.setup
      self
    end

    # Perform teardown
    #
    # @return [self]
    #
    # @api private
    #
    def self.teardown
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
    def self.kill(mutation)
      killer.new(self, mutation)
    end

    # Return killer
    #
    # @return [Class:Killer]
    #
    # @api private
    #
    def self.killer
      self::KILLER
    end

  end # Strategy
end # Mutant
