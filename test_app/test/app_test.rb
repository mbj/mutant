# encoding: UTF-8

require 'minitest/unit'
require 'mutant-minitest'

unless Mutant::Minitest.active?
  require 'minitest/autorun'
end

require 'pathname'

$LOAD_PATH << Pathname.new(__FILE__).parent.parent.join('lib').to_s

require 'test_app'

class TestLiteral < MiniTest::Unit::TestCase
  def test_command
    object = TestApp::Literal.new
    assert_equal(object, object.command(:foo))
  end

  def test_string
    object = TestApp::Literal.new
    assert_equal('string', object.string)
  end
end # TestLiteral
