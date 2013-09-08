# encoding: utf-8

module Mutant
  class Mutation
    class Filter
      # Mutation filter that filters on mutation codes
      class Code < self
        include Concord::Public.new(:code)

        # Test for match
        #
        # @param [Mutation] mutation
        #
        # @return [true]
        #   returns true if mutation code matches filter code
        #
        # @return [false]
        #   returns false otherwise
        #
        # @api private
        #
        def match?(mutation)
          mutation.code.eql?(code)
        end

        PATTERN = /\Acode:(?<code>[a-f0-9]{1,6})\z/.freeze

        # Test if class handles string
        #
        # @param [String] notation
        #
        # @return [Filter]
        #   return code filter instance if notation matches pattern
        #
        # @return [nil]
        #   returns nil otherwise
        #
        # @api private
        #
        def self.handle(notation)
          match = PATTERN.match(notation)
          return unless match
          new(match[:code])
        end

      end # Code
    end # Filter
  end # Mutation
end # Mutant
