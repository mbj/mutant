# frozen_string_literal: true

module Mutant
  module Repository
    class Diff
      module Ranges
        DECIMAL = /(?:0|[1-9]\d*)/.freeze
        REGEXP  = /\A@@ -(#{DECIMAL})(?:,(#{DECIMAL}))? \+(#{DECIMAL})(?:,(#{DECIMAL}))? @@/.freeze

        private_constant(*constants(false))

        # Parse a unified diff into ranges
        #
        # @param [String]
        #
        # @return [Set<Range<Integer>>]
        def self.parse(diff)
          diff.lines.flat_map(&method(:parse_ranges)).to_set
        end

        # Parse ranges from line
        #
        # @param [String] line
        #
        # @return [Array<Range<Integer>>]
        def self.parse_ranges(line)
          match = REGEXP.match(line) or return EMPTY_ARRAY

          match
            .captures
            .each_slice(2)
            .map { |start, offset| mk_range(start, offset) }
            .reject { |range| range.end < range.begin }
        end
        private_class_method :parse_ranges

        # Construct a range from start point and offset
        #
        # @param [String] start
        # @param [String, nil] offset
        #
        # @return [Range<Integer>]
        def self.mk_range(start, offset)
          start = Integer(start)

          ::Range.new(start, start + (offset ? Integer(offset).pred : 0))
        end
        private_class_method :mk_range
      end # Ranges
    end # Diff
  end # Repository
end # Ranges
