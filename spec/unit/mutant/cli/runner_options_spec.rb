require 'spec_helper'

shared_examples_for 'an invalid cli run' do
  it 'should raise error' do
    expect { subject }.to raise_error(described_class::Error, expected_message) 
  end
end

describe Mutant::CLI, '#runner_options' do
  subject { object.runner_options }

  let(:object) { described_class.new(arguments) }

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
    let(:arguments) { %w(--code) }

    let(:expected_message) { '"--code" is missing an argument' } 

    it_should_behave_like 'an invalid cli run'
  end

  context 'with explicit method matcher' do
    let(:arguments) { %w(TestApp::Literal#float) }
    
    let(:expected_options) do
      {
        :matcher         => Mutant::Matcher::Chain.new([Mutant::Matcher::Method.parse('TestApp::Literal#float')]),
        :mutation_filter => Mutant::Mutation::Filter::ALL,
        :killer          => Mutant::Killer::Rspec
      }
    end

    it { should eql(expected_options) }
  end

  context 'with library name' do
    let(:arguments) { %w(::TestApp) }
    
    let(:expected_options) do
      {
        :matcher         => Mutant::Matcher::Chain.new([Mutant::Matcher::ObjectSpace.new(%r(\ATestApp(::)?\z))]),
        :mutation_filter => Mutant::Mutation::Filter::ALL,
        :killer          => Mutant::Killer::Rspec
      }
    end

    it { should eql(expected_options) }
  end

  context 'with code filter' do
    let(:arguments) { %w(--code faa --code bbb TestApp::Literal#float) }

    let(:filters) do
      [
        Mutant::Mutation::Filter::Code.new('faa'),
        Mutant::Mutation::Filter::Code.new('bbb'),
      ]
    end

    let(:expected_options) do 
      { 
        :mutation_filter => Mutant::Mutation::Filter::Whitelist.new(filters),
        :matcher         => Mutant::Matcher::Chain.new([Mutant::Matcher::Method.parse('TestApp::Literal#float')]),
        :killer          => Mutant::Killer::Rspec
      }
    end

    it { should eql(expected_options) }
  end
end
