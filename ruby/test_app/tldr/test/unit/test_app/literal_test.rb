require 'tldr/autorun'
require 'mutant/tldr/coverage'

class LiteralTest < TLDR
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
