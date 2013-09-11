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

    # Build predicate from string
    #
    # @param [String] notation
    #
    # @return [Filter]
    #   when can be build from string
    #
    # @return [nil]
    #   otherwise
    #
    # @api private
    #
    def self.build(notation)
      descendants.each do |descendant|
        predicate = descendant.handle(notation)
        return predicate if predicate
      end

      nil
    end

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

    # Mutation predicate matching all mutations
    Mutant.singleton_subclass_instance('ALL', self) do

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
