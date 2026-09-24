# frozen_string_literal: true

module Mutant
  # Bootstrap process
  #
  # The role of the boostrap is to take the pure config and apply it against
  # the impure world to produce an environment.
  #
  # env = config interpreted against the world
  #
  # rubocop:disable Metrics/ModuleLength
  module Bootstrap
    include Adamantium, Anima.new(:config, :parser, :world)

    UNMATCHED_CONTEXT_MAP = <<~'MESSAGE'
      The coverage recording names no test that this suite runs, so it cannot
      say which tests cover a subject.

      Record it again from the project root, with the suite mutant runs. A suite
      that starts simplecov unconditionally rewrites the recording every time
      mutant runs it, so start simplecov only when measuring coverage.
    MESSAGE

    SEMANTICS_MESSAGE_FORMAT =
      "%<message>s. Fix your lib to follow normal ruby semantics!\n" \
      '{Module,Class}#name should return resolvable constant name as String or nil'

    CLASS_NAME_RAISED_EXCEPTION =
      '%<scope_class>s#name from: %<scope>s raised an error: %<exception>s'

    CLASS_NAME_TYPE_MISMATCH_FORMAT =
      '%<scope_class>s#name from: %<raw_scope>s returned %<name>s'

    private_constant(*constants(false))

    # Run Bootstrap
    #
    # @param [Env] env
    #
    # @return [Either<String, Env>]
    #
    # rubocop:disable Metrics/MethodLength
    def self.call(env)
      env.record(:bootstrap) do
        env = load_hooks(env)
          .tap(&method(:infect))
          .with(matchable_scopes: matchable_scopes(env))

        matched_subjects = env.record(:subject_match) do
          Matcher.expand(env:).call(env)
        end

        selected_subjects = subject_select(env, matched_subjects)

        mutations = env.record(:mutation_generate) do
          selected_subjects.flat_map(&:mutations)
        end

        setup_integration(
          env:,
          mutations:,
          selected_subjects:
        )
      end
    end
    # rubocop:enable Metrics/MethodLength

    # Run test only bootstrap
    #
    # @param [Env] env
    #
    # @return [Either<String, Env>]
    def self.call_test(env)
      env.record(:bootstrap) do
        env = load_hooks(env).tap(&method(:infect))
        setup_integration(
          env:               env,
          mutations:         [],
          selected_subjects: []
        )
      end
    end

    # rubocop:disable Metrics/MethodLength
    def self.setup_integration(env:, mutations:, selected_subjects:)
      env.record(__method__) do
        hooks = env.hooks
        hooks.run(:setup_integration_pre)
        Integration.setup(env).bind do |integration|
          setup_selector(env:, integration:).fmap do |selector|
            env.with(
              integration:,
              mutations:,
              selector:,
              subjects:    selected_subjects
            ).tap { hooks.run(:setup_integration_post) }
          end
        end
      end
    end
    private_class_method :setup_integration

    # The selector the configured strategy asks for
    #
    # The default is to use the coverage recording whenever there is a usable
    # one and the expressions otherwise, so a project that records per test
    # coverage gets the better selection without asking for it. Naming
    # `context_map` explicitly turns every reason the recording cannot be used
    # into a failed run, rather than a silent downgrade to a selection the user
    # did not ask for.
    #
    # @return [Either<String, Selector>]
    def self.setup_selector(env:, integration:)
      selection = env.config.selection
      fallback  = Selector::Expression.new(integration:)

      return Either::Right.new(fallback) if selection.expression?

      result = env.record(__method__) do
        ContextMap::Loader
          .call(path: env.world.pathname.new(selection.effective_path), world: env.world)
          .bind { |context_map| context_map_selector(context_map:, fallback:, integration:) }
      end

      selection.context_map? ? result : Either::Right.new(result.from_right { fallback })
    end
    private_class_method :setup_selector

    # A recording that names no test of this suite was taken somewhere else, and
    # answering selection from it would report every mutation alive without ever
    # running a test that could have killed it.
    #
    # @return [Either<String, Selector>]
    def self.context_map_selector(context_map:, fallback:, integration:)
      selector = Selector::ContextMap.new(context_map:, fallback:, integration:)

      selector.unmatched? ? Either::Left.new(UNMATCHED_CONTEXT_MAP) : Either::Right.new(selector)
    end
    private_class_method :context_map_selector

    # rubocop:enable Metrics/MethodLength
    def self.load_hooks(env)
      env.record(__method__) do
        env.with(hooks: Hooks.load_config(env.config))
      end
    end
    private_class_method :load_hooks

    def self.subject_select(env, subjects)
      env.record(__method__) do
        start_expressions = env.config.matcher.start_expressions

        return subjects if start_expressions.empty?

        subjects.drop_while do |subject|
          start_expressions.none? do |expression|
            expression.prefix?(subject.expression)
          end
        end
      end
    end
    private_class_method :subject_select

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def self.infect(env)
      env.record(__method__) do
        config, hooks, world = env.config, env.hooks, env.world

        env.record(:hooks_env_infection_pre) do
          hooks.run(:env_infection_pre, env:)
        end

        env.record(:require_target) do
          config.environment_variables.each do |key, value|
            world.environment_variables[key] = value
          end

          config.includes.each(&world.load_path.public_method(:<<))
          config.requires.each(&world.kernel.public_method(:require))
        end

        env.record(:hooks_env_infection_post) do
          hooks.run(:env_infection_post, env:)
        end
      end
    end
    private_class_method :infect
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/MethodLength

    def self.matchable_scopes(env)
      env.record(__method__) do
        config = env.config

        scopes = env.world.object_space.each_object(Module).with_object([]) do |raw_scope, aggregate|
          expression = expression(config.reporter, config.expression_parser, raw_scope) || next
          aggregate << Scope.new(raw: raw_scope, expression:)
        end

        scopes.sort_by { |scope| scope.expression.syntax }
      end
    end
    private_class_method :matchable_scopes

    def self.scope_name(reporter, raw_scope)
      raw_scope.name
    rescue => exception
      semantics_warning(
        reporter,
        CLASS_NAME_RAISED_EXCEPTION,
        exception:   exception.inspect,
        scope:       raw_scope,
        scope_class: raw_scope.class
      )
      nil
    end
    private_class_method :scope_name

    # rubocop:disable Metrics/MethodLength
    def self.expression(reporter, expression_parser, raw_scope)
      name = scope_name(reporter, raw_scope) or return

      unless name.instance_of?(String)
        semantics_warning(
          reporter,
          CLASS_NAME_TYPE_MISMATCH_FORMAT,
          name:,
          scope_class: raw_scope.class,
          raw_scope:
        )
        return
      end

      expression_parser.call(name).from_right {}
    end
    private_class_method :expression
    # rubocop:enable Metrics/MethodLength

    def self.semantics_warning(reporter, format, options)
      reporter.warn(SEMANTICS_MESSAGE_FORMAT % { message: format % options })
    end
    private_class_method :semantics_warning
  end # Bootstrap
  # rubocop:enable Metrics/ModuleLength
end # Mutant
