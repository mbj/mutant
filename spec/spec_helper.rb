# encoding: utf-8

require 'mutant'
require 'spec'
require 'spec/autorun'

# require spec support files and shared behavior
Dir[File.expand_path('../{support,shared}/**/*.rb', __FILE__)].each { |f| require f }

Spec::Runner.configure do |config|
  config.extend Spec::ExampleGroupMethods
end
