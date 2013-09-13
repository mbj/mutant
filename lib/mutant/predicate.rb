# encoding: utf-8

module Mutant
  # Abstract base class for predicates used to filter subjects / mutations
  class Predicate
    include Adamantium::Flat, AbstractType
    extend DescendantsTracker

    # Check for match
    #
    # @param [Object] object
    #
    # @return [true]
    #   if object is matched by predicate
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    abstract_method :match?

    # Return predicate for handle
    #
    # @param [String] _notation
    #
    # @return [nil]
    #
    # @api private
    #
    def self.handle(_notation)
      nil
    end

    # Mutation predicate matching no inputs
    Mutant.singleton_subclass_instance('CONTRADICTION', self) do

      # Test for match
      #
      # @pram [Mutation] _mutation
      #
      # @return [true]
      #
      # @api private
      #
      def match?(_mutation)
        false
      end

    end

    # Mutation predicate matching all inputs
    Mutant.singleton_subclass_instance('TAUTOLOGY', self) do

      # Test for match
      #
      # @pram [Mutation] _mutation
      #
      # @return [true]
      #
      # @api private
      #
      def match?(_mutation)
        true
      end

    end

  end # Filter
end # Mutant
