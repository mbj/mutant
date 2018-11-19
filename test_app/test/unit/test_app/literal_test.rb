require 'minitest/autorun'
require 'mutant/minitest/coverage'

class LiteralTest < Minitest::Test
  cover 'TestApp::Literal*'

  def test_command
    object = ::TestApp::Literal.new

    assert_equal(object, object.command('x'))
  end

  def test_string
    assert_equal('string', ::TestApp::Literal.new.string)
  end
end
