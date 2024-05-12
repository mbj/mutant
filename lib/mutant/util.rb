# frozen_string_literal: true

module Mutant
  # Utility methods
  module Util
    # Error raised by `Util.one` if size is less than zero or greater than one
    SizeError = Class.new(IndexError)

    # Return only element in array if it contains exactly one member
    #
    # @param array [Array]
    #
    # @return [Object] first entry
    def self.one(array)
      case array
      in [value]
        value
      else
        fail SizeError, "expected size to be exactly 1 but size was #{array.size}"
      end
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
        fail SizeError, "expected size to be max 1 but size was #{array.size}"
      end
    end
  end # Util
end # Mutant
