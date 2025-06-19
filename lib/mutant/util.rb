# frozen_string_literal: true

module Mutant
  # Utility methods
  module Util
    # Return only element in array if it contains exactly one member
    #
    # @param array [Array]
    #
    # @return [Object] first entry
    def self.one(array)
      Unparser::Util.one(array)
    end

    # Return only element in array if it contains max one member
    #
    # @param array [Array]
    #
    # @return [Object] first entry
    # @return [nil] if empty
    #
    # rubocop:disable Lint/EmptyInPattern
    def self.max_one(array)
      case array
      in []
      in [value]
        value
      else
        fail Unparser::Util::SizeError, "expected size to be max 1 but size was #{array.size}"
      end
    end
  end # Util
end # Mutant
