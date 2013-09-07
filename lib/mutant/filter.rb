module Mutant
  # Abstract base class for mutation/subject filters
  class Filter
    include Adamantium::Flat, AbstractType
    extend DescendantsTracker

    # Check for match
    #
    # @param [Object] object
    #
    # @return [true]
    #   if object is matched by filter
    #
    # @return [false]
    #   otherwise
    #
    # @api private
    #
    abstract_method :match?

    # Build filter from string
    #
    # @param [String] notation
    #
    # @return [Filter]
    #   when can be build from string
    #
    # @return [nil]
    #   returns nil otherwise
    #
    # @api private
    #
    def self.build(notation)
      descendants.each do |descendant|
        filter = descendant.handle(notation)
        return filter if filter
      end

      nil
    end

    # Return filter for handle
    #
    # @param [String] _notation
    #
    # @return [nil]
    #   returns nil
    #
    # @api private
    #
    def self.handle(_notation)
      nil
    end

    # Mutation filter matching all mutations
    Mutant.singleton_subclass_instance('ALL', self) do

      # Test for match
      #
      # @pram [Mutation] _mutation
      #
      # @return [true]
      #   returns true
      #
      # @api private
      #
      def match?(_mutation)
        true
      end

    end

  end # Filter
end # Mutant
