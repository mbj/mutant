module Mutant
  class Mutation
    # Abstract filter for mutations
    class Filter
      include Adamantium::Flat, AbstractType
      extend DescendantsTracker

      # Check for match
      #
      # @param [Mutation] mutation
      #
      # @return [true]
      #   returns true if mutation is matched by filter
      #
      # @return [false]
      #   returns false otherwise
      #
      # @api private
      #
      abstract_method :match?

      # Build filter from string
      #
      # @param [String] notation
      #
      # @return [Filter]
      #   returns filter when can be buld from string
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
  end # Mutation
end # Mutant
