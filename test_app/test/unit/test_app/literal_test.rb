require 'test_helper'

class TestApp::LiteralTest < TestAppTest
  cover 'TestApp::Literal*'

  def test_command
    object = ::TestApp::Literal.new
    subject = object.command('x')

    assert_equal object, subject
  end

  def test_string
    object = ::TestApp::Literal.new
    subject = object.string

    assert_equal 'string', subject
  end
end
