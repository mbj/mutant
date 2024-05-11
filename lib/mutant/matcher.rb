# frozen_string_literal: true

module Mutant
  # Abstract matcher to find subjects to mutate
  class Matcher
    include Adamantium, AbstractType

    # Call matcher
    #
    # @param [Env] env
    #
    # @return [Enumerable<Subject>]
    #
    abstract_method :call

    # Turn config into matcher
    #
    # @param [Env] env
    #
    # @return [Matcher]
    def self.expand(env:)
      matcher_config = env.config.matcher

      Filter.new(
        matcher:   Chain.new(matchers: matcher_config.subjects.map { |subject| subject.matcher(env: env) }),
        predicate: method(:allowed_subject?).curry.call(matcher_config)
      )
    end

    def self.allowed_subject?(config, subject)
      select_subject?(config, subject) && !ignore_subject?(config, subject) && !subject.inline_disabled?
    end
    private_class_method :allowed_subject?

    def self.select_subject?(config, subject)
      config.diffs.all? do |diff|
        diff.touches?(subject.source_path, subject.source_lines)
      end
    end
    private_class_method :select_subject?

    # Predicate that tests for ignored subject
    #
    # @param [Config] config
    # @param [Subject] subject
    #
    # @return [Boolean]
    def self.ignore_subject?(config, subject)
      config.ignore.any? do |expression|
        expression.prefix?(subject.expression)
      end
    end
    private_class_method :ignore_subject?
  end # Matcher
end # Mutant
