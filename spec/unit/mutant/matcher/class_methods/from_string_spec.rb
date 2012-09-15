require 'spec_helper'

describe Mutant::Matcher, '.from_string' do
  subject { object.from_string(input) }

  let(:input)   { mock('Input')   }
  let(:matcher) { mock('Matcher') }

  let(:descendant_a) { mock('Descendant A', :parse => nil) }
  let(:descendant_b) { mock('Descendant B', :parse => nil) }

  let(:object) { described_class }

  before do
    described_class.stub(:descendants => [descendant_a, descendant_b])
  end

  context 'when no descendant takes the input' do
    it { should be(nil) }

    it_should_behave_like 'an idempotent method'
  end

  context 'when one descendant handles input' do
    before do
      descendant_a.stub(:parse => matcher)
    end

    it { should be(matcher) }

    it_should_behave_like 'an idempotent method'
  end

  context 'when more than one descendant handles input' do
    let(:matcher_b) { mock('Matcher B') }

    before do
      descendant_a.stub(:parse => matcher)
      descendant_b.stub(:parse => matcher_b)
    end

    it 'should return the first matcher' do 
      should be(matcher)
    end

    it_should_behave_like 'an idempotent method'
  end
end

