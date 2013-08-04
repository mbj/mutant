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

  its(:filter)   { should eql(expected_filter)   }
  its(:strategy) { should eql(expected_strategy) }
  its(:reporter) { should eql(expected_reporter) }
  its(:matcher)  { should eql(expected_matcher)  }
end

describe Mutant::CLI, '.new' do
  let(:object) { described_class }
  let(:time)   { Time.now        }

  before do
    Time.stub(:now => time)
  end

  # Defaults
  let(:expected_filter)   { Mutant::Mutation::Filter::ALL      }
  let(:expected_strategy) { Mutant::Strategy::Rspec.new        }
  let(:expected_reporter) { Mutant::Reporter::CLI.new($stdout) }

  let(:ns)    { Mutant::CLI::Classifier }
  let(:cache) { Mutant::Cache.new       }

  let(:cli) { object.new(arguments) }

  subject { cli }

  context 'with unknown flag' do
    let(:arguments) { %w(--invalid) }

    let(:expected_message) { 'invalid option: --invalid' }

    it_should_behave_like 'an invalid cli run'
  end

  context 'with unknown option' do
    let(:arguments) { %w(--invalid Foo) }

    let(:expected_message) { 'invalid option: --invalid' }

    it_should_behave_like 'an invalid cli run'
  end

  context 'with many strategy flags' do
    let(:arguments) { %w(--static-fail --rspec TestApp) }
    let(:expected_matcher) { Mutant::CLI::Classifier::Namespace::Flat.new(Mutant::Cache.new, 'TestApp') }

    it_should_behave_like 'a cli parser'
  end

  context 'without arguments' do
    let(:arguments) { [] }

    let(:expected_message) { 'No strategy was set!' }

    it_should_behave_like 'an invalid cli run'
  end

  context 'with code filter and missing argument' do
    let(:arguments)        { %w(--rspec --code)    }
    let(:expected_message) { 'missing argument: --code' }

    it_should_behave_like 'an invalid cli run'
  end

  context 'with explicit method matcher' do
    let(:arguments)        { %w(--rspec TestApp::Literal#float) }
    let(:expected_matcher) { ns::Method.new(cache, 'TestApp::Literal#float') }

    it_should_behave_like 'a cli parser'
  end

  context 'with debug flag' do
    let(:matcher)          { '::TestApp*'                                 }
    let(:arguments)        { %W(--debug --rspec #{matcher})               }
    let(:expected_matcher) { ns::Namespace::Recursive.new(cache, matcher) }

    it_should_behave_like 'a cli parser'

    it 'should set the debug option' do
      subject.config.debug.should be(true)
    end
  end

  context 'with zombie flag' do
    let(:matcher)          { '::TestApp*'                                 }
    let(:arguments)        { %W(--zombie --rspec #{matcher})              }
    let(:expected_matcher) { ns::Namespace::Recursive.new(cache, matcher) }

    it_should_behave_like 'a cli parser'

    it 'should set the zombie option' do
      subject.config.zombie.should be(true)
    end
  end

  context 'with namespace matcher' do
    let(:matcher)          { '::TestApp*'                                 }
    let(:arguments)        { %W(--rspec #{matcher})                       }
    let(:expected_matcher) { ns::Namespace::Recursive.new(cache, matcher) }

    it_should_behave_like 'a cli parser'
  end

  context 'with code filter' do
    let(:matcher)   { 'TestApp::Literal#float'                     }
    let(:arguments) { %W(--rspec --code faa --code bbb #{matcher}) }

    let(:filters) do
      [
        Mutant::Mutation::Filter::Code.new('faa'),
        Mutant::Mutation::Filter::Code.new('bbb'),
      ]
    end

    let(:expected_matcher) { ns::Method.new(cache, 'TestApp::Literal#float')  }
    let(:expected_filter)  { Mutant::Mutation::Filter::Whitelist.new(filters) }

    it_should_behave_like 'a cli parser'
  end
end
