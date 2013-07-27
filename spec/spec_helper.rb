require 'mutant'
require 'devtools'
Devtools.init_spec_helper

$: << File.join(TestApp.root,'lib')

require 'test_app'

module Fixtures
  AST_CACHE = Mutant::Cache.new
end

module ParserHelper
  def generate(node)
    Unparser.unparse(node)
  end

  def parse(string)
    Parser::CurrentRuby.parse(string)
  end
end

RSpec.configure do |config|
  config.include(CompressHelper)
  config.include(ParserHelper)
  config.include(Mutant::NodeHelpers)
  config.mock_with :rspec do |rspec|
    rspec.syntax = [:expect, :should]
  end
end
