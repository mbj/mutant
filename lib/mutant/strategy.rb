# encoding: utf-8

module Mutant

  # Abstract base class for killing strategies
  class Strategy
    include AbstractType, Adamantium::Flat, Equalizer.new

    REGISTRY = {}

    # Lookup strategy for name
    #
    # @param [String] name
    #
    # @return [Strategy]
    #   if found
    #
    # @api private
    #
    def self.lookup(name)
      REGISTRY.fetch(name)
    end

    # Register strategy
    #
    # @param [String] name
    #
    # @return [undefined]
    #
    # @api private
    #
    def self.register(name)
      REGISTRY[name] = self
    end
    private_class_method :register

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

    # Null strategy that never kills a mutation
    class Null < self

      register 'null'

      KILLER = Killer::Null

    end # Null

  end # Strategy

end # Mutant
