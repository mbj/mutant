# frozen_string_literal: true

module Mutant
  class Matcher
    # Subject matcher configuration
    class Config
      include Adamantium, Anima.new(
        :ignore,
        :subjects,
        :start_expressions,
        :diffs
      )

      INSPECT_FORMAT      = "#<#{self} %s>".freeze
      ATTRIBUTE_DELIMITER = ' '
      ATTRIBUTE_FORMAT    = '%s: [%s]'
      ENUM_DELIMITER      = ','
      EMPTY_ATTRIBUTES    = 'empty'
      PRESENTATIONS       = {
        ignore:            :syntax,
        start_expressions: :syntax,
        subjects:          :syntax,
        diffs:             :inspect
      }.freeze

      private_constant(*constants(false))

      DEFAULT = new(anima.attribute_names.to_h { |name| [name, []] })

      expression = Transform::Block.capture(:expression) do |input|
        Mutant::Config::DEFAULT.expression_parser.call(input)
      end

      expression_array = Transform::Array.new(transform: expression)

      LOADER =
        Transform::Sequence.new(
          steps: [
            Transform::Hash.new(
              optional: [
                Transform::Hash::Key.new(
                  transform: expression_array,
                  value:     'subjects'
                ),
                Transform::Hash::Key.new(
                  transform: expression_array,
                  value:     'ignore'
                )
              ],
              required: []
            ),
            Transform::Hash::Symbolize.new,
            ->(attributes) { Either::Right.new(DEFAULT.with(attributes)) }
          ]
        )

      # Inspection string
      #
      # @return [String]
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
      def add(attribute, value)
        with(attribute => public_send(attribute) + [value])
      end

      # Merge with other config
      #
      # @param [Config] other
      #
      # @return [Config]
      def merge(other)
        with(
          ignore:            ignore + other.ignore,
          start_expressions: start_expressions + other.start_expressions,
          subjects:          other.subjects.any? ? other.subjects : subjects,
          diffs:             diffs + other.diffs
        )
      end

    private

      def present_attributes
        to_h.reject { |_key, value| value.empty? }.keys
      end

      def inspect_attributes
        attributes = present_attributes
          .map(&method(:format_attribute))
          .join(ATTRIBUTE_DELIMITER)

        attributes.empty? ? EMPTY_ATTRIBUTES : attributes
      end

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
