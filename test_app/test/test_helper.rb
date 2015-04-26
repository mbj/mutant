$LOAD_PATH << File.join(File.dirname(__FILE__), '../lib')

require 'test_app'
require 'minitest/autorun'

# require spec support files and shared behavior
Dir[File.expand_path('../{support,shared}/**/*.rb', __FILE__)].each do |file|
  require file
end

class TestAppTest < Minitest::Test
  def self.cover(expression)
    @expression = expression
  end

  def self.cover_expression
    unless @expression
      fail "Cover expression for #{self} is not specified"
    end

    @expression
  end
end
