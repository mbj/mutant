# frozen_string_literal: true

module Mutant
  module Range
    # Test if two ranges overlap
    #
    # @param [Range] left
    # @param [Range] right
    #
    # @return [Boolean]
    def self.overlap?(left, right)
      left.end >= right.begin && right.end >= left.begin
    end
  end # Range
end # Mutant
