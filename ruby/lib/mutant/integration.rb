# frozen_string_literal: true

module Mutant

  # Abstract base class mutant test framework integrations
  class Integration
    include AbstractType, Adamantium, Anima.new(
      :arguments,
      :expression_parser,
      :world
    )

    LOAD_MESSAGE = <<~'MESSAGE'
      Unable to load integration mutant-%<integration_name>s:
      %<exception>s
      You may have to install the gem mutant-%<integration_name>s!
    MESSAGE

    CONST_MESSAGE = <<~'MESSAGE'
      Unable to load integration mutant-%<integration_name>s:
      %<exception>s
      This is a bug in the integration you have to report.
      The integration is supposed to define %<constant_name>s!
    MESSAGE

    INTEGRATION_MISSING = <<~'MESSAGE'
      No test framework integration configured.
      See https://github.com/mbj/mutant/blob/master/docs/configuration.md#integration
    MESSAGE

    private_constant(*constants(false))

    class Config
      include Adamantium, Anima.new(:name, :arguments)

      DEFAULT = new(arguments: EMPTY_ARRAY, name: nil)

      TRANSFORM = Transform::Sequence.new(
        steps: [
          Transform::Primitive.new(primitive: Hash),
          Transform::Hash.new(
            optional: [
              Transform::Hash::Key.new(transform: Transform::STRING,       value: 'name'),
              Transform::Hash::Key.new(transform: Transform::STRING_ARRAY, value: 'arguments')
            ],
            required: []
          ),
          Transform::Hash::Symbolize.new,
          Transform::Success.new(block: DEFAULT.method(:with))
        ]
      )

      def merge(other)
        self.class.new(
          name:      other.name || name,
          arguments: arguments + other.arguments
        )
      end
    end # Config

    # Setup integration
    #
    # @param env [Bootstrap]
    #
    # @return [Either<String, Integration>]
    def self.setup(env)
      integration_config = env.config.integration

      return Either::Left.new(INTEGRATION_MISSING) unless integration_config.name

      attempt_require(env).bind { attempt_const_get(env) }.fmap do |klass|
        klass.new(
          arguments:         integration_config.arguments,
          expression_parser: env.config.expression_parser,
          world:             env.world
        ).setup
      end
    end

    # rubocop:disable Style/MultilineBlockChain
    def self.attempt_require(env)
      integration_name = env.config.integration.name

      Either.wrap_error(LoadError) do
        env.world.kernel.require("mutant/integration/#{integration_name}")
      end.lmap do |exception|
        LOAD_MESSAGE % {
          exception:        exception.inspect,
          integration_name:
        }
      end
    end
    private_class_method :attempt_require
    # rubocop:enable Style/MultilineBlockChain

    def self.attempt_const_get(env)
      integration_name = env.config.integration.name
      constant_name    = integration_name.capitalize

      Either.wrap_error(NameError) { const_get(constant_name) }.lmap do |exception|
        CONST_MESSAGE % {
          constant_name:    "#{self}::#{constant_name}",
          exception:        exception.inspect,
          integration_name:
        }
      end
    end
    private_class_method :attempt_const_get

    # Perform integration setup
    #
    # @return [self]
    def setup = self

    # Run a collection of tests
    #
    # @param [Enumerable<Test>] tests
    #
    # @return [Result::Test]
    abstract_method :call

    # All tests this integration can run
    #
    # Some tests may not be available for mutation testing.
    # See #available_tests
    #
    # @return [Enumerable<Test>]
    abstract_method :all_tests

    # All tests available for mutation testing
    #
    # Subset ofr #al_tests
    #
    # @return [Enumerable<Test>]
    abstract_method :available_tests

  private

    def timer = world.timer
  end # Integration
end # Mutant
