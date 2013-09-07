# encoding: utf-8

module Mutant
  class Filter
    # Blacklist filter
    class Blacklist < self
      include Adamantium::Flat, Concord.new(:blacklist)

      # Test for match
      #
      # @param [Object] object
      #
      # @return [true]
      #   if object matches blacklist
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def match?(object)
        blacklist.none? { |filter| filter.match?(object) }
      end

    end # Whitelist
  end # Filter
end # Mutant
