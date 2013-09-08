# encoding: utf-8

require 'equalizer'
require 'devtools/spec_helper'

if ENV['COVERAGE'] == 'true'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
 ]

  SimpleCov.start do
    command_name     'spec:unit'
    add_filter       'config'
    add_filter       'spec'
    add_filter       'test_app'
    minimum_coverage 89.65  # TODO: raise this to 100, then mutation test
  end
end

require 'mutant'

$LOAD_PATH << File.join(TestApp.root, 'lib')

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
