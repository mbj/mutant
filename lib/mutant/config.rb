module Mutant
  # Standalone configuration of a mutant execution.
  #
  # Does not reference any "external" volatile state. The configuration applied
  # to current environment is being represented by the Mutant::Env object.
  class Config
    include Adamantium::Flat, Anima.new(
      :debug,
      :expected_coverage,
      :fail_fast,
      :includes,
      :integration,
      :isolation,
      :jobs,
      :matcher,
      :requires,
      :reporter,
      :zombie
    )

    %i[fail_fast zombie debug].each do |name|
      define_method(:"#{name}?") { public_send(name) }
    end

    boolean = Morpher.sexp { s(:guard, s(:boolean)) }

    string_array = Morpher.sexp do
      s(:map, s(:primitive, String))
    end

    integration = Morpher.sexp do
      s(:block,
        s(:guard, s(:primitive, String)),
        s(:custom, [Mutant::Integration.method(:setup), :name.to_proc])
      )
    end

    load_isolation = lambda do |input|
      fail unless input.eql?('fork')
      Mutant::Isolation::Fork
    end

    isolation = Morpher.sexp do
      s(:custom, [load_isolation, ->(_isolation) { 'fork' }])
    end

    expression_array = Morpher.sexp do
      s(:block,
        s(:guard, s(:primitive, Array)),
        s(:map, s(:custom, [Mutant::Expression.method(:parse), :syntax.to_proc]))
      )
    end

    matcher = Morpher.sexp do
      s(:block,
        s(:guard, s(:primitive, Hash)),
        s(:hash_transform,
          s(:key_symbolize, :match_expressions, expression_array),
          s(:key_symbolize, :subject_ignores,   expression_array),
          s(:key_symbolize, :subject_selects,   expression_array)
        ),
        s(:anima_load, Matcher::Config)
      )
    end

    load_cli = lambda do |input|
      fail unless input.eql?('cli')
      Mutant::Reporter::CLI.build($stdout)
    end

    reporter = Morpher.sexp do
      s(:custom, [load_cli, ->(_reporter) { 'cli' }])
    end

    LOADER = Morpher.build do
      s(:block,
        s(:hash_transform,
          s(:key_symbolize, :debug,             boolean),
          s(:key_symbolize, :expected_coverage, s(:guard, s(:primitive, Rational))),
          s(:key_symbolize, :fail_fast,         boolean),
          s(:key_symbolize, :includes,          string_array),
          s(:key_symbolize, :integration,       integration),
          s(:key_symbolize, :isolation,         isolation),
          s(:key_symbolize, :jobs,              s(:guard, s(:primitive, Fixnum))),
          s(:key_symbolize, :matcher,           matcher),
          s(:key_symbolize, :requires,          string_array),
          s(:key_symbolize, :reporter,          reporter),
          s(:key_symbolize, :zombie,            boolean)
        ),
        s(:anima_load, Config)
      )
    end

    # Load configuration from hash
    #
    # @param [Hash] input
    #
    # @return [Config]
    #
    # @api private
    #
    def self.load(input)
      evaluation = LOADER.evaluation(input)
      unless evaluation.success?
        $stderr.puts(evaluation.description)
        fail 'Config could not be loaded'
      end
      evaluation.output
    end

    # Load config from file
    #
    # @param [Pathname] path
    #
    # @return [Config]
    #
    # @api private
    #
    def self.load_file(path)
      load(YAML.load_file(path))
    end

    DEFAULT_LOCATION_PATTERN = '{.mutant,config/mutant.yml}'.freeze

    # Load default config
    #
    # @return [Config]
    #
    # @api private
    #
    def self.load_default
      files = Pathname.glob(Pathname.pwd.join(DEFAULT_LOCATION_PATTERN))

      if files.length > 1
        fail "More than one config file found in default locations: #{files}"
      end

      if files.empty?
        fail "No config file found in default locations: #{DEFAULT_LOCATION_PATTERN}"
      end

      load_file(files.first)
    end

  end # Config
end # Mutant
