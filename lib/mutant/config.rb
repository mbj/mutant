# frozen_string_literal: true

module Mutant
  # Standalone configuration of a mutant execution.
  #
  # Does not reference any "external" volatile state. The configuration applied
  # to current environment is being represented by the Mutant::Env object.
  class Config
    include Adamantium::Flat, Anima.new(
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

    boolean = Transform::Boolean.new
    float   = Transform::Primitive.new(Float)
    integer = Transform::Primitive.new(Integer)
    string  = Transform::Primitive.new(String)

    string_array = Transform::Array.new(string)

    TRANSFORM = Transform::Sequence.new(
      [
        Transform::Exception.new(SystemCallError, :read.to_proc),
        Transform::Exception.new(YAML::SyntaxError, YAML.method(:safe_load)),
        Transform::Hash.new(
          optional: [
            Transform::Hash::Key.new('fail_fast',        boolean),
            Transform::Hash::Key.new('includes',         string_array),
            Transform::Hash::Key.new('integration',      string),
            Transform::Hash::Key.new('jobs',             integer),
            Transform::Hash::Key.new('mutation_timeout', float),
            Transform::Hash::Key.new('requires',         string_array)
          ],
          required: []
        ),
        Transform::Hash::Symbolize.new
      ]
    )

    MORE_THAN_ONE_CONFIG_FILE = <<~'MESSAGE'
      Found more than one candidate for use as implicit config file: %s
    MESSAGE

    CANDIDATES = %w[
      .mutant.yml
      config/mutant.yml
      mutant.yml
    ].freeze

    # Merge with other config
    #
    # @param [Config] other
    #
    # @return [Config]
    def merge(other)
      other.with(
        fail_fast:        fail_fast || other.fail_fast,
        includes:         includes + other.includes,
        jobs:             other.jobs || jobs,
        integration:      other.integration || integration,
        mutation_timeout: other.mutation_timeout || mutation_timeout,
        matcher:          matcher.merge(other.matcher),
        requires:         requires + other.requires,
        zombie:           zombie || other.zombie
      )
    end

    private_constant(*constants(false))

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
  end # Config
end # Mutant
