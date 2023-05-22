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
      :mutation,
      :reporter,
      :requires
    )

    %i[fail_fast].each do |name|
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

    MUTATION_TIMEOUT_DEPRECATION = <<~'MESSAGE'
      Deprecated configuration toplevel key `mutation_timeout` found.

      This key will be removed in the next major version.
      Instead place your mutation timeout configuration under the `mutation` key
      like this:

      ```
      # mutant.yml
      mutation:
        timeout: 10.0 # float here.
      ```
    MESSAGE

    INTEGRATION_DEPRECATION = <<~'MESSAGE'
      Deprecated configuration toplevel string key `integration` found.

      This key will be removed in the next major version.
      Instead place your integration configuration under the `integration.name` key
      like this:

      ```
      # mutant.yml
      integration:
        name: your_integration # typically rspec or minitest
      ```
    MESSAGE

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
        integration:           integration.merge(other.integration),
        jobs:                  other.jobs || jobs,
        matcher:               matcher.merge(other.matcher),
        mutation:              mutation.merge(other.mutation),
        requires:              requires + other.requires
      )
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    # Load config file
    #
    # @param [Env] env
    #
    # @return [Either<String,Config>]
    def self.load_config_file(env)
      files = CANDIDATES
        .map(&env.world.pathname.public_method(:new))
        .select(&:readable?)

      if files.one?
        load_contents(env, files.first).fmap(&DEFAULT.public_method(:with))
      elsif files.empty?
        Either::Right.new(DEFAULT)
      else
        Either::Left.new(MORE_THAN_ONE_CONFIG_FILE % files.join(', '))
      end
    end

    def self.load_contents(env, path)
      Transform::Named
        .new(
          name:      path.to_s,
          transform: sequence(env.config.reporter)
        )
        .call(path)
        .lmap(&:compact_message)
    end
    private_class_method :load_contents

    def self.sequence(reporter)
      Transform::Sequence.new(
        steps: [
          Transform::Exception.new(error_class: SystemCallError,   block: :read.to_proc),
          Transform::Exception.new(error_class: YAML::SyntaxError, block: YAML.public_method(:safe_load)),
          Transform::Primitive.new(primitive: Hash),
          Transform::Success.new(block: ->(hash) { deprecations(reporter, hash) }),
          *TRANSFORMS
        ]
      )
    end
    private_class_method :sequence

    # The configuration from the environment
    #
    # @return [Config]
    def self.env
      DEFAULT.with(jobs: Etc.nprocessors)
    end

    PATHNAME_ARRAY = Transform::Array.new(
      transform: Transform::Sequence.new(
        steps: [
          Transform::STRING,
          Transform::Exception.new(error_class: ArgumentError, block: Pathname.public_method(:new))
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

    def self.deprecations(reporter, hash)
      mutation_timeout_deprecation(reporter, hash)
      integration_deprecation(reporter, hash)

      hash
    end
    private_class_method :deprecations

    def self.mutation_timeout_deprecation(reporter, hash)
      return unless hash.key?('mutation_timeout')
      reporter.warn(MUTATION_TIMEOUT_DEPRECATION)

      (hash['mutation'] ||= {})['timeout'] ||= hash.delete('mutation_timeout')
    end
    private_class_method :mutation_timeout_deprecation

    def self.integration_deprecation(reporter, hash)
      value = hash['integration']
      return unless value.instance_of?(String)
      reporter.warn(INTEGRATION_DEPRECATION)

      hash['integration'] = { 'name' => value }
    end
    private_class_method :integration_deprecation

    TRANSFORMS = [
      Transform::Hash.new(
        optional: [
          Transform::Hash::Key.new(
            transform: ->(value) { CoverageCriteria::TRANSFORM.call(value) },
            value:     'coverage_criteria'
          ),
          Transform::Hash::Key.new(
            transform: Transform::Sequence.new(
              steps: [
                Transform::Primitive.new(primitive: Hash),
                Transform::Block.capture(:environment_variables, &method(:parse_environment_variables))
              ]
            ),
            value:     'environment_variables'
          ),
          Transform::Hash::Key.new(
            transform: Transform::BOOLEAN,
            value:     'fail_fast'
          ),
          Transform::Hash::Key.new(
            transform: PATHNAME_ARRAY,
            value:     'hooks'
          ),
          Transform::Hash::Key.new(
            transform: Transform::STRING_ARRAY,
            value:     'includes'
          ),
          Transform::Hash::Key.new(
            transform: ->(value) { Integration::Config::TRANSFORM.call(value) },
            value:     'integration'
          ),
          Transform::Hash::Key.new(
            transform: Transform::INTEGER,
            value:     'jobs'
          ),
          Transform::Hash::Key.new(
            transform: Matcher::Config::LOADER,
            value:     'matcher'
          ),
          Transform::Hash::Key.new(
            transform: Mutation::Config::TRANSFORM,
            value:     'mutation'
          ),
          Transform::Hash::Key.new(
            transform: Transform::STRING_ARRAY,
            value:     'requires'
          )
        ],
        required: []
      ),
      Transform::Hash::Symbolize.new
    ].freeze

    private_constant(:TRANSFORMS)
  end # Config
  # rubocop:enable Metrics/ClassLength
end # Mutant
