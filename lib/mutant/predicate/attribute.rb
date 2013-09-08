# encoding: utf-8

module Mutant
  class Predicate
    # Base class for predicates on object attributes
    class Attribute < self
      include Concord.new(:attribute_name, :expectation)

    private

      # Return value for object
      #
      # @param [Object] object
      #
      # @return [Object]
      #
      # @api private
      #
      def value(object)
        object.public_send(attribute_name)
      end

      # Regexp based attribute predicate
      class Regexp < self

        # Test for match
        #
        # @param [Object] object
        #
        # @return [true]
        #   if attribute value matches expectation
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def match?(object)
          !!(expectation =~ value(object))
        end

      end # Regexp

      # Equality based attribute predicate
      class Equality < self

        # Test for match
        #
        # @param [Object] object
        #
        # @return [true]
        #   if attribute value matches expectation
        #
        # @return [false]
        #   otherwise
        #
        # @api private
        #
        def match?(object)
          expectation.eql?(value(object))
        end

        PATTERN = /\A(code):([a-f0-9]{1,6})\z/.freeze

        # Test if class handles string
        #
        # @param [String] notation
        #
        # @return [Filter]
        #   if notation matches pattern
        #
        # @return [nil]
        #   otherwise
        #
        # @api private
        #
        def self.handle(notation)
          match = PATTERN.match(notation)
          return unless match
          new(match[1].to_sym, match[2])
        end

      end # Equality
    end # Attribute
  end # Filter
end # Mutant
