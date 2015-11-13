if ENV['COVERAGE'] == 'true'
  require 'simplecov'

  SimpleCov.start do
    command_name 'spec:unit'

    add_filter 'config'
    add_filter 'spec'
    add_filter 'vendor'
    add_filter 'test_app'
    add_filter 'lib/mutant/meta/*'
    add_filter 'lib/mutant/zombifier'
    add_filter 'lib/mutant/zombifier/*'
    # Trace points shadow each other under 2.0 (fixed in 2.1)
    add_filter 'lib/mutant/line_trace.rb' if RUBY_VERSION.eql?('2.0.0')

    minimum_coverage 100
  end
end

require 'tempfile'
require 'concord'
require 'anima'
require 'adamantium'
require 'devtools/spec_helper'
require 'unparser/cli'
require 'mutant'
require 'mutant/meta'
Devtools.init_spec_helper

$LOAD_PATH << File.join(TestApp.root, 'lib')

require 'test_app'

module Fixtures
  TEST_CONFIG = Mutant::Config::DEFAULT.with(reporter: Mutant::Reporter::Trace.new)
  TEST_ENV    = Mutant::Env::Bootstrap.(TEST_CONFIG)
end # Fixtures

module ParserHelper
  def generate(node)
    Unparser.unparse(node)
  end

  def test_env
    Fixtures::TEST_ENV.with(
      config: Mutant::Config::DEFAULT.with(reporter: Mutant::Reporter::Trace.new)
    )
  end

  def parse(string)
    Unparser::Preprocessor.run(Parser::CurrentRuby.parse(string))
  end

  def parse_expression(string)
    Mutant::Config::DEFAULT.expression_parser.(string)
  end
end

module MessageHelper
  def message(*arguments)
    Mutant::Actor::Message.new(*arguments)
  end
end

RSpec.configure do |config|
  config.extend(SharedContext)
  config.include(CompressHelper)
  config.include(MessageHelper)
  config.include(ParserHelper)
  config.include(Mutant::AST::Sexp)
end
