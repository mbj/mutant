# frozen_string_literal: true

module Mutant
  # Bootstrap process
  #
  # The role of the boostrap is to take the pure config and apply it against
  # the impure world to produce an environment.
  #
  # env = config interpreted against the world
  module Bootstrap
    include Adamantium::Flat, Anima.new(:config, :parser, :world)

    SEMANTICS_MESSAGE_FORMAT =
      "%<message>s. Fix your lib to follow normal ruby semantics!\n" \
      '{Module,Class}#name should return resolvable constant name as String or nil'

    CLASS_NAME_RAISED_EXCEPTION =
      '%<scope_class>s#name from: %<scope>s raised an error: %<exception>s'

    CLASS_NAME_TYPE_MISMATCH_FORMAT =
      '%<scope_class>s#name from: %<scope>s returned %<name>s'

    private_constant(*constants(false))

    # Run Bootstrap
    #
    # @param [World] world
    # @param [Config] config
    #
    # @return [Either<String, Env>]
    #
    # rubocop:disable Metrics/MethodLength
    def self.apply(world, config)
      env = Env
        .empty(world, config)
        .tap(&method(:infect))
        .with(matchable_scopes: matchable_scopes(world, config))

      subjects = Matcher.from_config(env.config.matcher).call(env)

      Integration.setup(env).fmap do |integration|
        env.with(
          integration: integration,
          mutations:   subjects.flat_map(&:mutations),
          selector:    Selector::Expression.new(integration),
          subjects:    subjects
        )
      end
    end
    # rubocop:enable Metrics/MethodLength

    def self.infect(env)
      config, world = env.config, env.world

      config.includes.each(&world.load_path.method(:<<))
      config.requires.each(&world.kernel.method(:require))
    end
    private_class_method :infect

    def self.matchable_scopes(world, config)
      scopes = world.object_space.each_object(Module).each_with_object([]) do |scope, aggregate|
        expression = expression(config.reporter, config.expression_parser, scope) || next
        aggregate << Scope.new(scope, expression)
      end

      scopes.sort_by { |scope| scope.expression.syntax }
    end
    private_class_method :matchable_scopes

    def self.scope_name(reporter, scope)
      scope.name
    rescue => exception
      semantics_warning(
        reporter,
        CLASS_NAME_RAISED_EXCEPTION,
        exception:   exception.inspect,
        scope:       scope,
        scope_class: scope.class
      )
      nil
    end
    private_class_method :scope_name

    # rubocop:disable Metrics/MethodLength
    def self.expression(reporter, expression_parser, scope)
      name = scope_name(reporter, scope) or return

      unless name.instance_of?(String)
        semantics_warning(
          reporter,
          CLASS_NAME_TYPE_MISMATCH_FORMAT,
          name:        name,
          scope_class: scope.class,
          scope:       scope
        )
        return
      end

      expression_parser.apply(name).from_right {}
    end
    private_class_method :expression
    # rubocop:enable Metrics/MethodLength

    def self.semantics_warning(reporter, format, options)
      reporter.warn(SEMANTICS_MESSAGE_FORMAT % { message: format % options })
    end
    private_class_method :semantics_warning
  end # Bootstrap
end # Mutant
