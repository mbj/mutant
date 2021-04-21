# frozen_string_literal: true

module Mutant
  class Matcher
    # Subject matcher configuration
    class Config
      include Adamantium, Anima.new(
        :ignore,
        :subjects,
        :start_expressions,
        :subject_filters
      )

      INSPECT_FORMAT      = "#<#{self} %s>"
      ATTRIBUTE_DELIMITER = ' '
      ATTRIBUTE_FORMAT    = '%s: [%s]'
      ENUM_DELIMITER      = ','
      EMPTY_ATTRIBUTES    = 'empty'
      PRESENTATIONS       = {
        ignore:            :syntax,
        start_expressions: :syntax,
        subject_filters:   :inspect,
        subjects:          :syntax
      }.freeze

      private_constant(*constants(false))

      DEFAULT = new(anima.attribute_names.map { |name| [name, []] }.to_h)

      expression = Transform::Block.capture(:expression) do |input|
        Mutant::Config::DEFAULT.expression_parser.call(input)
      end

      expression_array = Transform::Array.new(expression)

      LOADER =
        Transform::Sequence.new(
          [
            Transform::Hash.new(
              optional: [
                Transform::Hash::Key.new('subjects', expression_array),
                Transform::Hash::Key.new('ignore', expression_array)
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
        self.class.new(
          to_h
            .map { |name, value| [name, value + other.public_send(name)] }
            .to_h
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
