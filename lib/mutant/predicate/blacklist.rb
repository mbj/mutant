# encoding: utf-8

module Mutant
  class Predicate
    # Blacklist predicate
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
        blacklist.none? { |predicate| predicate.match?(object) }
      end

    end # Whitelist
  end # Filter
end # Mutant
