# encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '../lib')

require 'test_app'
require 'rspec'

# require spec support files and shared behavior
Dir[File.expand_path('../{support,shared}/**/*.rb', __FILE__)].each { |f| require f }
