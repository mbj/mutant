# frozen_string_literal: true

module Mutant
  # Standalone configuration of a mutant execution.
  #
  # Does not reference any "external" volatile state. The configuration applied
  # to current environment is being represented by the Mutant::Env object.
  class Config
    include Adamantium::Flat, Anima.new(
      :coverage_criteria,
      :expression_parser,
      :fail_fast,
      :includes,
      :integration,
      :isolation,
      :jobs,
      :matcher,
      :mutation_timeout,
      :reporter,
      :requires,
      :zombie
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

    class CoverageCriteria
      include Anima.new(:process_abort, :test_result, :timeout)

      DEFAULT = new(
        process_abort: false,
        test_result:   true,
        timeout:       false
      )

      TRANSFORM =
        Transform::Sequence.new(
          [
            Transform::Hash.new(
              optional: [
                Transform::Hash::Key.new('process_abort', Transform::BOOLEAN),
                Transform::Hash::Key.new('test_result',   Transform::BOOLEAN),
                Transform::Hash::Key.new('timeout',       Transform::BOOLEAN)
              ],
              required: []
            ),
            Transform::Hash::Symbolize.new,
            ->(value) { Either::Right.new(DEFAULT.with(**value)) }
          ]
        )
    end # CoverageCriteria

    # Merge with other config
    #
    # @param [Config] other
    #
    # @return [Config]
    def merge(other)
      other.with(
        fail_fast:        fail_fast || other.fail_fast,
        includes:         other.includes + includes,
        jobs:             other.jobs || jobs,
        integration:      other.integration || integration,
        mutation_timeout: other.mutation_timeout || mutation_timeout,
        matcher:          matcher.merge(other.matcher),
        requires:         other.requires + requires,
        zombie:           zombie || other.zombie
      )
    end

    # Load config file
    #
    # @param [World] world
    # @param [Config] config
    #
    # @return [Either<String,Config>]
    def self.load_config_file(world)
      config = DEFAULT
      files = CANDIDATES.map(&world.pathname.public_method(:new)).select(&:readable?)

      if files.one?
        load_contents(files.first).fmap(&config.public_method(:with))
      elsif files.empty?
        Either::Right.new(config)
      else
        Either::Left.new(MORE_THAN_ONE_CONFIG_FILE % files.join(', '))
      end
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

    TRANSFORM = Transform::Sequence.new(
      [
        Transform::Exception.new(SystemCallError, :read.to_proc),
        Transform::Exception.new(YAML::SyntaxError, YAML.method(:safe_load)),
        Transform::Hash.new(
          optional: [
            Transform::Hash::Key.new('coverage_criteria', CoverageCriteria::TRANSFORM),
            Transform::Hash::Key.new('fail_fast',         Transform::BOOLEAN),
            Transform::Hash::Key.new('includes',          Transform::STRING_ARRAY),
            Transform::Hash::Key.new('integration',       Transform::STRING),
            Transform::Hash::Key.new('jobs',              Transform::INTEGER),
            Transform::Hash::Key.new('mutation_timeout',  Transform::FLOAT),
            Transform::Hash::Key.new('requires',          Transform::STRING_ARRAY)
          ],
          required: []
        ),
        Transform::Hash::Symbolize.new
      ]
    )

    private_constant(:TRANSFORM)
  end # Config
end # Mutant
