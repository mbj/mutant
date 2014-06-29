if ENV['COVERAGE'] == 'true'
  require 'simplecov'

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
 ]

  SimpleCov.start do
    command_name 'spec:unit'

    add_filter 'config'
    add_filter 'spec'
    add_filter 'vendor'
    add_filter 'test_app'
    add_filter 'lib/mutant/meta/*'

    minimum_coverage 89.77  # TODO: raise this to 100, then mutation test
  end
end

require 'concord'
require 'adamantium'
require 'devtools/spec_helper'
require 'unparser/cli'
require 'mutant'
require 'mutant/meta'

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
    Unparser::Preprocessor.run(Parser::CurrentRuby.parse(string))
  end
end

RSpec.configure do |config|
  config.include(CompressHelper)
  config.include(ParserHelper)
  config.include(Mutant::AST::Sexp)

  config.expect_with :rspec do |rspec|
    rspec.syntax = :expect
  end
end
