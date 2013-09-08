# encoding: utf-8

module Mutant
  class CLI
    # A classifier for input strings
    class Classifier < Matcher
      include AbstractType, Adamantium::Flat, Concord.new(:cache, :match)

      include Equalizer.new(:identifier)

      SCOPE_NAME_PATTERN = /[A-Za-z][A-Za-z\d_]*/.freeze
      SCOPE_OPERATOR     = '::'.freeze
      CBASE_PATTERN      = /\A#{SCOPE_OPERATOR}/.freeze

      METHOD_NAME_PATTERN = Regexp.union(
        /[A-Za-z_][A-Za-z\d_]*[!?=]?/,
        *OPERATOR_METHODS.map(&:to_s)
      ).freeze

      SCOPE_PATTERN = /
        (?:#{SCOPE_OPERATOR})?#{SCOPE_NAME_PATTERN}
        (?:#{SCOPE_OPERATOR}#{SCOPE_NAME_PATTERN})*
      /x.freeze

      REGISTRY = []

      # Register classifier
      #
      # @return [undefined]
      #
      # @api private
      #
      def self.register
        REGISTRY << self
      end
      private_class_method :register

      # Return constant
      #
      # @param [String] location
      #
      # @return [Class|Module]
      #
      # @api private
      #
      def self.constant_lookup(location)
        location
          .sub(CBASE_PATTERN, EMPTY_STRING)
          .split(SCOPE_OPERATOR)
          .reduce(Object) do |parent, name|
            parent.const_get(name, nil)
        end
      end

      # Return matchers for input
      #
      # @return [Classifier]
      #   if a classifier handles the input
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def self.build(*arguments)
        classifiers = REGISTRY.map { |descendant| descendant.run(*arguments) }
        classifiers.compact!
        raise if classifiers.length > 1
        classifiers.first
      end

      # Run classifier
      #
      # @param [Cache] cache
      #
      # @param [String] input
      #
      # @return [Classifier]
      #   if input is handled by classifier
      #
      # @return [nil]
      #   otherwise
      #
      # @api private
      #
      def self.run(cache, input)
        match = self::REGEXP.match(input)
        return unless match

        new(cache, match)
      end

      # No protected_class_method in ruby :(
      class << self; protected :run; end

      # Enumerate subjects
      #
      # @return [self]
      #   if block given
      #
      # @return [Enumerator<Subject>]
      #   otherwise
      #
      # @api private
      #
      def each(&block)
        return to_enum unless block_given?
        matcher.each(&block)
        self
      end

      # Return identifier
      #
      # @return [String]
      #
      # @api private
      #
      def identifier
        match.to_s
      end
      memoize :identifier

      # Return matcher
      #
      # @return [Matcher]
      #
      # @api private
      #
      abstract_method :matcher
      private         :matcher

    end # Classifier
  end # CLI
end # Mutant
