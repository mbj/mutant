module Mutant
  class Env
    # Bootstrap environment
    class Bootstrap
      include Adamantium::Flat, Concord::Public.new(:config), Procto.call(:env)

      SEMANTICS_MESSAGE_FORMAT =
        "%<message>s. Fix your lib to follow normal ruby semantics!\n" \
        '{Module,Class}#name should return resolvable constant name as String or nil'.freeze

      CLASS_NAME_RAISED_EXCEPTION =
        '%<scope_class>s#name from: %<scope>s raised an error: %<exception>s'.freeze

      CLASS_NAME_TYPE_MISMATCH_FORMAT =
        '%<scope_class>s#name from: %<scope>s returned %<name>s'.freeze

      private_constant(*constants(false))

      # Scopes that are eligible for matching
      #
      # @return [Enumerable<Matcher::Scope>]
      attr_reader :matchable_scopes

      # Parser for this environment
      #
      # @return [Parser]
      attr_reader :parser

      # Initialize object
      #
      # @return [Object]
      def initialize(*)
        super
        @parser = Parser.new
        infect
        initialize_matchable_scopes
      end

      # Print warning message
      #
      # @param [String]
      #
      # @return [self]
      def warn(message)
        config.reporter.warn(message)
        self
      end

      # Environment after bootstraping
      #
      # @return [Env]
      # rubocop:disable MethodLength
      #
      def env
        subjects = matched_subjects
        Env.new(
          actor_env:        Actor::Env.new(Thread),
          config:           config,
          integration:      integration,
          matchable_scopes: matchable_scopes,
          mutations:        subjects.flat_map(&:mutations),
          parser:           parser,
          selector:         Selector::Expression.new(integration),
          subjects:         subjects
        )
      end

    private

      # Configured mutant integration
      #
      # @return [Mutant::Integration]
      attr_reader :integration

      # Scope name from scoping object
      #
      # @param [Class, Module] scope
      #
      # @return [String]
      #   if scope has a name and does not raise exceptions obtaining it
      #
      # @return [nil]
      #   otherwise
      def scope_name(scope)
        scope.name
      rescue => exception
        semantics_warning(
          CLASS_NAME_RAISED_EXCEPTION,
          exception:   exception.inspect,
          scope:       scope,
          scope_class: scope.class
        )
        nil
      end

      # Infect environment
      #
      # @return [undefined]
      def infect
        config.includes.each(&config.load_path.method(:<<))
        config.requires.each(&config.kernel.method(:require))
        @integration = config.integration.new(config).setup
      end

      # Matched subjects
      #
      # @return [Enumerable<Subject>]
      def matched_subjects
        Matcher::Compiler.call(config.matcher).call(self)
      end

      # Initialize matchable scopes
      #
      # @return [undefined]
      def initialize_matchable_scopes
        scopes = ObjectSpace.each_object(Module).each_with_object([]) do |scope, aggregate|
          expression = expression(scope) || next
          aggregate << Scope.new(scope, expression)
        end

        @matchable_scopes = scopes.sort_by { |scope| scope.expression.syntax }
      end

      # Try to turn scope into expression
      #
      # @param [Class, Module] scope
      #
      # @return [Expression]
      #   if scope can be represented in an expression
      #
      # @return [nil]
      #   otherwise
      def expression(scope)
        name = scope_name(scope) or return

        unless name.instance_of?(String)
          semantics_warning(
            CLASS_NAME_TYPE_MISMATCH_FORMAT,
            name:        name,
            scope_class: scope.class,
            scope:       scope
          )
          return
        end

        config.expression_parser.try_parse(name)
      end

      # Write a semantics warning
      #
      # @return [undefined]
      def semantics_warning(format, options)
        message = format % options
        warn(SEMANTICS_MESSAGE_FORMAT % { message: message })
      end
    end # Bootstrap
  end # Env
end # Mutant
