# encoding: utf-8
require 'test_app'
require 'rspec'

$: << File.join(File.dirname(__FILE__), 'lib')


# require spec support files and shared behavior
Dir[File.expand_path('../{support,shared}/**/*.rb', __FILE__)].each { |f| require f }
