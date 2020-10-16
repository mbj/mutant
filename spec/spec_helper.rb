# frozen_string_literal: true

require 'adamantium'
require 'anima'
require 'concord'
require 'mutant'
require 'mutant/meta'
require 'rspec/its'
require 'timeout'
require 'tempfile'
require 'tmpdir'

require './spec/shared/framework_integration_behavior'
require './spec/shared/method_matcher_behavior'
require './spec/support/corpus'
require './spec/support/file_system'
require './spec/support/ice_nine_config'
require './spec/support/ruby_vm'
require './spec/support/shared_context'
require './spec/support/xspec'

$LOAD_PATH << File.expand_path('../test_app/lib', __dir__)

require 'test_app'

module Fixtures
  TEST_CONFIG = Mutant::Config::DEFAULT
    .with(reporter: Mutant::Reporter::Null.new)

  TEST_ENV = Mutant::Bootstrap
    .apply(Mutant::WORLD, TEST_CONFIG).from_right

end # Fixtures

module ParserHelper
  def generate(node)
    Unparser.unparse(node)
  end

  def parse(string)
    Unparser.parse(string)
  end

  def parse_expression(string)
    Mutant::Config::DEFAULT.expression_parser.apply(string).from_right
  end
end # ParserHelper

module XSpecHelper
  def verify_events
    expectations = raw_expectations
      .map(&XSpec::MessageExpectation.method(:parse))

    XSpec::ExpectationVerifier.verify(self, expectations) do
      yield
    end
  end

  def undefined
    double('undefined')
  end
end # XSpecHelper

RSpec.configuration.around(file_path: %r{spec/unit}) do |example|
  Timeout.timeout(2, &example)
end

RSpec.shared_examples_for 'a command method' do
  it 'returns self' do
    should equal(object)
  end
end

RSpec.shared_examples_for 'an idempotent method' do
  it 'is idempotent' do
    first = subject
    fail 'RSpec not configured for threadsafety' unless RSpec.configuration.threadsafe?
    mutex    = __memoized.instance_variable_get(:@mutex)
    memoized = __memoized.instance_variable_get(:@memoized)

    mutex.synchronize { memoized.delete(:subject) }
    should equal(first)
  end
end

RSpec.configure do |config|
  config.extend(SharedContext)
  config.include(ParserHelper)
  config.include(Mutant::AST::Sexp)
  config.include(XSpecHelper)
end
