# encoding: utf-8

module Mutant

  # Abstract base class for killing strategies
  class Strategy
    include AbstractType, Adamantium::Flat

    # Perform strategy setup
    #
    # @return [self]
    #
    # @api private
    #
    def setup
      self
    end

    # Perform strategy teardown
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

  private

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
