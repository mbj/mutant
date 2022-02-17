# frozen_string_literal: true

module Mutant
  # Standalone configuration of a mutant execution.
  #
  # Does not reference any "external" volatile state. The configuration applied
  # to current environment is being represented by the Mutant::Env object.
  #
  # rubocop:disable Metrics/ClassLength
  class Config
    include Adamantium, Anima.new(
      :coverage_criteria,
      :environment_variables,
      :expression_parser,
      :fail_fast,
      :hooks,
      :includes,
      :integration,
      :isolation,
      :jobs,
      :matcher,
      :mutation_timeout,
      :reporter,
      :requires,
      :zombie,
      :compacted_log
    )

    %i[fail_fast zombie].each do |name|
      define_method(:"#{name}?") { public_send(name) }
    end

    MORE_THAN_ONE_CONFIG_FILE = <<~'MESSAGE'
      Found more than one candidate for use as implicit config file: %s
    MESSAGE

    CANDIDATES = %w[
      .mutant.yml
      config/mutant.yml
      mutant.yml
    ].freeze

    private_constant(*constants(false))

    # Merge with other config
    #
    # @param [Config] other
    #
    # @return [Config]
    #
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def merge(other)
      other.with(
        coverage_criteria:     coverage_criteria.merge(other.coverage_criteria),
        environment_variables: environment_variables.merge(other.environment_variables),
        fail_fast:             fail_fast || other.fail_fast,
        hooks:                 hooks + other.hooks,
        includes:              includes + other.includes,
        integration:           other.integration || integration,
        jobs:                  other.jobs || jobs,
        matcher:               matcher.merge(other.matcher),
        mutation_timeout:      other.mutation_timeout || mutation_timeout,
        requires:              requires + other.requires,
        zombie:                zombie || other.zombie,
        compacted_log:             other.compacted_log || compacted_log
      )
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # Load config file
    #
    # @param [World] world
    # @param [Config] config
    #
    # @return [Either<String,Config>]
    def self.load_config_file(world)
      files = CANDIDATES
        .map(&world.pathname.public_method(:new))
        .select(&:readable?)

      if files.one?
        load_contents(files.first).fmap(&DEFAULT.public_method(:with))
      elsif files.empty?
        Either::Right.new(DEFAULT)
      else
        Either::Left.new(MORE_THAN_ONE_CONFIG_FILE % files.join(', '))
      end
    end

    # Expand config with defaults
    #
    # @return [Config]
    def expand_defaults
      with(
        coverage_criteria: CoverageCriteria::DEFAULT.merge(coverage_criteria),
        jobs:              jobs || 1
      )
    end

    def self.load_contents(path)
      Transform::Named
        .new(path.to_s, TRANSFORM)
        .call(path)
        .lmap(&:compact_message)
    end
    private_class_method :load_contents

    # The configuration from the environment
    #
    # @return [Config]
    def self.env
      DEFAULT.with(jobs: Etc.nprocessors)
    end

    PATHNAME_ARRAY = Transform::Array.new(
      Transform::Sequence.new(
        [
          Transform::STRING,
          Transform::Exception.new(ArgumentError, Pathname.public_method(:new))
        ]
      )
    )

    # Parse a hash of environment variables
    #
    # @param [Hash<Object,Object>]
    #
    # @return [Either<String,Hash<String,String>]
    #
    def self.parse_environment_variables(hash)
      invalid = hash.keys.reject { |key| key.instance_of?(String) }
      return Either::Left.new("Non string keys: #{invalid}") if invalid.any?

      invalid = hash.keys.grep_v(ENV_VARIABLE_KEY_REGEXP)
      return Either::Left.new("Invalid keys: #{invalid}") if invalid.any?

      invalid = hash.values.reject { |value| value.instance_of?(String) }
      return Either::Left.new("Non string values: #{invalid}") if invalid.any?

      Either::Right.new(hash)
    end
    TRANSFORM = Transform::Sequence.new(
      [
        Transform::Exception.new(SystemCallError, :read.to_proc),
        Transform::Exception.new(YAML::SyntaxError, YAML.public_method(:safe_load)),
        Transform::Hash.new(
          optional: [
            Transform::Hash::Key.new('coverage_criteria', ->(value) { CoverageCriteria::TRANSFORM.call(value) }),
            Transform::Hash::Key.new(
              'environment_variables',
              Transform::Sequence.new(
                [
                  Transform::Primitive.new(Hash),
                  Transform::Block.capture(:environment_variables, &method(:parse_environment_variables))
                ]
              )
            ),
            Transform::Hash::Key.new('fail_fast',             Transform::BOOLEAN),
            Transform::Hash::Key.new('hooks',                 PATHNAME_ARRAY),
            Transform::Hash::Key.new('includes',              Transform::STRING_ARRAY),
            Transform::Hash::Key.new('integration',           Transform::STRING),
            Transform::Hash::Key.new('compacted_log',         Transform::BOOLEAN),
            Transform::Hash::Key.new('jobs',                  Transform::INTEGER),
            Transform::Hash::Key.new('matcher',               Matcher::Config::LOADER),
            Transform::Hash::Key.new('mutation_timeout',      Transform::FLOAT),
            Transform::Hash::Key.new('requires',              Transform::STRING_ARRAY)
          ],
          required: []
        ),
        Transform::Hash::Symbolize.new
      ]
    )

    private_constant(:TRANSFORM)
  end # Config
  # rubocop:enable Metrics/ClassLength
end # Mutant
