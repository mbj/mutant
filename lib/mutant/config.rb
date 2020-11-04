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
      :reporter,
      :requires,
      :zombie
    )

    %i[fail_fast zombie].each do |name|
      define_method(:"#{name}?") { public_send(name) }
    end

    boolean = Transform::Boolean.new
    integer = Transform::Primitive.new(Integer)
    string  = Transform::Primitive.new(String)

    string_array = Transform::Array.new(string)

    TRANSFORM = Transform::Sequence.new(
      [
        Transform::Exception.new(SystemCallError, :read.to_proc),
        Transform::Exception.new(YAML::SyntaxError, YAML.method(:safe_load)),
        Transform::Hash.new(
          optional: [
            Transform::Hash::Key.new('fail_fast',   boolean),
            Transform::Hash::Key.new('includes',    string_array),
            Transform::Hash::Key.new('integration', string),
            Transform::Hash::Key.new('jobs',        integer),
            Transform::Hash::Key.new('requires',    string_array)
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

    private_constant(*constants(false))

    # Load config file
    #
    # @param [World] world
    # @param [Config] config
    #
    # @return [Either<String,Config>]
    def self.load_config_file(world, config)
      files = CANDIDATES.map(&world.pathname.method(:new)).select(&:readable?)

      if files.one?
        load_contents(files.first).fmap(&config.method(:with))
      elsif files.empty?
        Either::Right.new(config)
      else
        Either::Left.new(MORE_THAN_ONE_CONFIG_FILE % files.join(', '))
      end
    end

    def self.load_contents(path)
      Transform::Named
        .new(path.to_s, TRANSFORM)
        .apply(path)
        .lmap(&:compact_message)
    end
    private_class_method :load_contents
  end # Config
end # Mutant
