# encoding: utf-8

require 'spec_helper'

shared_examples_for 'an invalid cli run' do
  it 'should raise error' do
    expect do
      subject
    end.to raise_error(Mutant::CLI::Error, expected_message)
  end
end

shared_examples_for 'a cli parser' do
  subject { cli.config }

  it { expect(subject.strategy).to eql(expected_strategy) }
  it { expect(subject.reporter).to eql(expected_reporter) }
  it { expect(subject.matcher).to eql(expected_matcher)   }
end

describe Mutant::CLI, '.new' do
  let(:object) { described_class }
  let(:time)   { Time.now        }

  before do
    Time.stub(now: time)
  end

  # Defaults
  let(:expected_filter)   { Morpher.evaluator(s(:true))        }
  let(:expected_strategy) { Mutant::Strategy::Null.new         }
  let(:expected_reporter) { Mutant::Reporter::CLI.new($stdout) }

  let(:ns)    { Mutant::Matcher   }
  let(:cache) { Mutant::Cache.new }

  let(:cli) { object.new(arguments) }

  subject { cli }

  context 'with unknown flag' do
    let(:arguments) { %w[--invalid] }

    let(:expected_message) { 'invalid option: --invalid' }

    it_should_behave_like 'an invalid cli run'
  end

  context 'with unknown option' do
    let(:arguments) { %w[--invalid Foo] }

    let(:expected_message) { 'invalid option: --invalid' }

    it_should_behave_like 'an invalid cli run'
  end

  context 'without arguments' do
    let(:arguments) { [] }

    let(:expected_message) { 'No patterns given' }

    it_should_behave_like 'an invalid cli run'
  end

  context 'with code filter and missing argument' do
    let(:arguments)        { %w[--code]                 }
    let(:expected_message) { 'missing argument: --code' }

    it_should_behave_like 'an invalid cli run'
  end

  context 'with explicit method pattern' do
    let(:arguments)        { %w[TestApp::Literal#float] }

    let(:expected_matcher) do
      ns::Method::Instance.new(cache, TestApp::Literal, TestApp::Literal.instance_method(:float))
    end

    it_should_behave_like 'a cli parser'
  end

  context 'with debug flag' do
    let(:pattern)          { 'TestApp*'           }
    let(:arguments)        { %W[--debug #{pattern}] }
    let(:expected_matcher) { ns::Namespace.new(cache, 'TestApp') }

    it_should_behave_like 'a cli parser'

    it 'should set the debug option' do
      expect(subject.config.debug).to be(true)
    end
  end

  context 'with zombie flag' do
    let(:pattern)          { 'TestApp*'            }
    let(:arguments)        { %W[--zombie #{pattern}] }
    let(:expected_matcher) { ns::Namespace.new(cache, 'TestApp') }

    it_should_behave_like 'a cli parser'

    it 'should set the zombie option' do
      expect(subject.config.zombie).to be(true)
    end
  end

  context 'with namespace pattern' do
    let(:pattern)          { 'TestApp*' }
    let(:arguments)        { [pattern]    }
    let(:expected_matcher) { ns::Namespace.new(cache, 'TestApp') }

    it_should_behave_like 'a cli parser'
  end

  context 'with subject code filter' do
    let(:pattern)   { 'TestApp::Literal#float' }
    let(:arguments) { %W[--code faa --code bbb #{pattern}] }

    let(:expected_filter) do
      Morpher.evaluator(
        s(:mxor,
          s(:eql, s(:attribute, :code), s(:value, 'faa')),
          s(:eql, s(:attribute, :code), s(:value, 'bbb'))
        )
      )
    end

    let(:expected_matcher) do
      matcher = ns::Method::Instance.new(
        cache,
        TestApp::Literal, TestApp::Literal.instance_method(:float)
      )
      predicate = Morpher.compile(
        s(:or,
          s(:eql,
            s(:attribute, :code),
            s(:static, 'faa')
          ),
          s(:eql,
            s(:attribute, :code),
            s(:static, 'bbb')
          )
        )
      )
      ns::Filter.new(matcher, predicate)
    end

    it_should_behave_like 'a cli parser'
  end
end
