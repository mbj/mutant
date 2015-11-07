module Mutant
  class Matcher
    # Subject matcher configuration
    class Config
      include Adamantium, Anima.new(
        :match_expressions,
        :ignore_expressions,
        :subject_filters
      )

      INSPECT_FORMAT      = "#<#{self} %s>".freeze
      ATTRIBUTE_DELIMITER = ' '.freeze
      ATTRIBUTE_FORMAT    = '%s: [%s]'.freeze
      ENUM_DELIMITER      = ','.freeze
      EMPTY_ATTRIBUTES    = 'empty'.freeze
      PRESENTATIONS       = IceNine.deep_freeze(
        match_expressions:  :to_s,
        ignore_expressions: :to_s,
        subject_filters:    :inspect
      )
      private_constant(*constants(false))

      DEFAULT = new(Hash[anima.attribute_names.map { |name| [name, []] }])

      # Inspection string
      #
      # @return [String]
      #
      # @api private
      def inspect
        INSPECT_FORMAT % inspect_attributes
      end
      memoize :inspect

      # Add value to configurable collection
      #
      # @param [Symbol] attribute
      # @param [Object] value
      #
      # @return [Config]
      #
      # @api private
      def add(attribute, value)
        with(attribute => public_send(attribute) + [value])
      end

    private

      # Present attributes
      #
      # @return [Array<Symbol>]
      #
      # @api private
      def present_attributes
        to_h.reject { |_key, value| value.empty? }.keys
      end

      # Formatted attributes
      #
      # @return [String]
      #
      # @api private
      def inspect_attributes
        attributes = present_attributes
          .map(&method(:format_attribute))
          .join(ATTRIBUTE_DELIMITER)

        attributes.empty? ? EMPTY_ATTRIBUTES : attributes
      end

      # Format attribute
      #
      # @param [Symbol] attribute_name
      #
      # @return [String]
      def format_attribute(attribute_name)
        ATTRIBUTE_FORMAT %
          [
            attribute_name,
            public_send(attribute_name)
              .map(&PRESENTATIONS.fetch(attribute_name))
              .join(ENUM_DELIMITER)
          ]
      end

    end # Config
  end # Matcher
end # Mutant
