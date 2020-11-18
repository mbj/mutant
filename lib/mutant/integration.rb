# frozen_string_literal: true

module Mutant

  # Abstract base class mutant test framework integrations
  class Integration
    include AbstractType, Adamantium::Flat, Anima.new(:expression_parser, :timer)

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

    private_constant(*constants(false))

    # Setup integration
    #
    # @param env [Bootstrap]
    #
    # @return [Either<String, Integration>]
    def self.setup(env)
      attempt_require(env).bind { attempt_const_get(env) }.fmap do |klass|
        klass.new(
          expression_parser: env.config.expression_parser,
          timer:             env.world.timer
        ).setup
      end
    end

    # rubocop:disable Style/MultilineBlockChain
    def self.attempt_require(env)
      integration_name = env.config.integration

      Either.wrap_error(LoadError) do
        env.world.kernel.require("mutant/integration/#{integration_name}")
      end.lmap do |exception|
        LOAD_MESSAGE % {
          exception:        exception.inspect,
          integration_name: integration_name
        }
      end
    end
    private_class_method :attempt_require
    # rubocop:enable Style/MultilineBlockChain

    def self.attempt_const_get(env)
      integration_name = env.config.integration
      constant_name    = integration_name.capitalize

      Either.wrap_error(NameError) { const_get(constant_name) }.lmap do |exception|
        CONST_MESSAGE % {
          constant_name:    "#{self}::#{constant_name}",
          exception:        exception.inspect,
          integration_name: integration_name
        }
      end
    end
    private_class_method :attempt_const_get

    # Perform integration setup
    #
    # @return [self]
    def setup
      self
    end

    # Run a collection of tests
    #
    # @param [Enumerable<Test>] tests
    #
    # @return [Result::Test]
    abstract_method :call

    # Available tests for integration
    #
    # @return [Enumerable<Test>]
    abstract_method :all_tests
  end # Integration
end # Mutant
