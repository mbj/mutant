module Mutant
  class Mutation
    class Filter

      # Whiltelist filter
      class Whitelist < self
        include Adamantium::Flat, Equalizer.new(:whitelist)

        # Test for match
        #
        # @param [Mutation] mutation
        #
        # @return [true]
        #   returns true if mutation matches whitelist
        #
        # @return [false]
        #   returns false otherwise
        #
        # @api private
        #
        def match?(mutation)
          @whitelist.any? { |filter| filter.match?(mutation) }
        end

        # Return whitelist
        #
        # @return [Enumerable<Filter>]
        #
        # @api private
        #
        attr_reader :whitelist

      private

        # Initalize white list
        #
        # @param [Enumerable<Filter>] whitelist
        #
        # @return [undefined]
        #
        # @api private
        #
        def initialize(whitelist)
          @whitelist = whitelist
        end
      end
    end
  end
end
