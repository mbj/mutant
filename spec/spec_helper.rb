# encoding: utf-8

require 'devtools'
Devtools.init_spec_helper

$: << File.join(TestApp.root,'lib')

require 'test_app'
require 'mutant'

RSpec.configure do |config|
  config.include(CompressHelper)
end
