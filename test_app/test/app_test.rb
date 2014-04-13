# encoding: UTF-8

if ENV.key?('MUTANT')
  require 'minitest/unit'
else
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

module MiniTest

  # Return tests that kill given subject
  #
  # @example
  #
  #   tests = MiniTest.mutant_killers(a_mutant_subject)
  #
  # @param [Mutant::Subject] subject
  #   the subject under mutation
  #
  # @return [Enumerable<#run(runner)>]
  #   the tests that are supposed to kill mutations on given subject
  #   most the runnables are most likely instances of MinitTest::Unit::TestCase
  #
  # @api public
  #
  def self.mutant_killers(subject)
    [ TestLiteral.new(:test_string) ]
  end

end # Minitest
