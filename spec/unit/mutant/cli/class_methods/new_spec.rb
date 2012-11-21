require 'spec_helper'

shared_examples_for 'an invalid cli run' do
  it 'should raise error' do
    expect { subject }.to raise_error(described_class::Error, expected_message) 
  end
end

shared_examples_for 'a cli parser' do
  its(:filter)   { should eql(expected_filter) }
  its(:killer)   { should eql(expected_killer)          }
  its(:reporter) { should eql(expected_reporter)        }
  its(:matcher)  { should eql(expected_matcher)         }
end

describe Mutant::CLI, '.new' do

  before do
    pending
  end

  let(:object) { described_class }

  # Defaults
  let(:expected_filter)          { Mutant::Mutation::Filter::ALL      }
  let(:expected_killer)          { Mutant::Killer::Rspec::Forking     }
  let(:expected_reporter)        { Mutant::Reporter::CLI.new($stderr) }

  subject { object.new(arguments) }

  context 'with unknown option' do
    let(:arguments) { %w(--invalid Foo) }

    let(:expected_message) { 'Unknown option: "--invalid"' }

    it_should_behave_like 'an invalid cli run'
  end

  context 'without arguments' do
    let(:arguments) { [] }

    let(:expected_message) { 'No matchers given' }

    it_should_behave_like 'an invalid cli run'
  end

  context 'with code filter and missing argument' do
    let(:arguments) { %w(--rspec-unit --code) }

    let(:expected_message) { '"--code" is missing an argument' } 

    it_should_behave_like 'an invalid cli run'
  end

  context 'with explicit method matcher' do
    let(:arguments) { %w(TestApp::Literal#float) }

    let(:expected_matcher) { Mutant::Matcher::Method.parse('TestApp::Literal#float') }

    it_should_behave_like 'a cli parser'

  end

  context 'with library name' do
    let(:arguments) { %w(::TestApp) }
    
    let(:expected_matcher) { Mutant::Matcher::ObjectSpace.new(%r(\ATestApp(\z|::))) }

    it_should_behave_like 'a cli parser'
  end

  context 'with code filter' do
    let(:arguments) { %w(--code faa --code bbb TestApp::Literal#float) }

    let(:filters) do
      [
        Mutant::Mutation::Filter::Code.new('faa'),
        Mutant::Mutation::Filter::Code.new('bbb'),
      ]
    end

    let(:expected_matcher) { Mutant::Matcher::Method.parse('TestApp::Literal#float') }
    let(:expected_filter)  { Mutant::Mutation::Filter::Whitelist.new(filters)        }

    it_should_behave_like 'a cli parser'
  end
end
