# encoding: utf-8

module Mutant
  class Predicate

    # Whiltelist filter
    class Whitelist < self
      include Adamantium::Flat, Concord.new(:whitelist)

      # Test for match
      #
      # @param [Object] object
      #
      # @return [true]
      #   if mutation matches whitelist
      #
      # @return [false]
      #   otherwise
      #
      # @api private
      #
      def match?(object)
        whitelist.any? { |filter| filter.match?(object) }
      end

    end # Whitelist
  end # Predicate
end # Mutant
