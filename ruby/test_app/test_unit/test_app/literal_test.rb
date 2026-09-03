require 'test/unit'
require 'mutant/test_unit/coverage'

class LiteralTest < Test::Unit::TestCase
  cover 'TestApp::Literal*'
  cover 'TestApp::Literal#string'

  def test_command
    object = ::TestApp::Literal.new

    assert_equal(object, object.command('x'))
  end

  def test_string
    assert_equal('string', ::TestApp::Literal.new.string)
  end
end
