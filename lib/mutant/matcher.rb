# frozen_string_literal: true

module Mutant
  # Abstract matcher to find subjects to mutate
  class Matcher
    include Adamantium::Flat, AbstractType

    # Call matcher
    #
    # @param [Env] env
    #
    # @return [Enumerable<Subject>]
    #
    abstract_method :call

    # Turn config into matcher
    #
    # @param [Config] config
    #
    # @return [Matcher]
    def self.from_config(config)
      Filter.new(
        Chain.new(config.match_expressions.map(&:matcher)),
        method(:allowed_subject?).curry.call(config)
      )
    end

    # Test if subject is allowed do
    #
    # @param [Config] config
    # @param [Subject] subject
    #
    # @return [Boolean]
    def self.allowed_subject?(config, subject)
      select_subject?(config, subject) && !ignore_subject?(config, subject)
    end
    private_class_method :allowed_subject?

    # Predicate that tests for selected subject
    #
    # @param [Config] config
    # @param [Subject] subject
    #
    # @return [Boolean]
    #
    # @api private
    def self.select_subject?(config, subject)
      config.subject_filters.all? { |filter| filter.call(subject) }
    end
    private_class_method :select_subject?

    # Predicate that tests for ignored subject
    #
    # @param [Config] config
    # @param [Subject] subject
    #
    # @return [Boolean]
    def self.ignore_subject?(config, subject)
      config.ignore_expressions.any? do |expression|
        expression.prefix?(subject.expression)
      end
    end
  end # Matcher
end # Mutant
