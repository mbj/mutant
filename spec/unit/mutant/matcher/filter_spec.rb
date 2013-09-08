require 'spec_helper'

describe Mutant::Matcher::Filter do
  let(:object)    { described_class.new(matcher, predicate) }
  let(:matcher)   { [:foo, :bar] }

  let(:predicate) { Mutant::Predicate::Attribute::Equality.new(:to_s, 'foo') }

  describe '#each' do
    subject { object.each { |item| yields << item } }

    let(:yields) { []                 }
    its(:to_a)   { should eql([:bar]) }

    it_should_behave_like 'an #each method'
  end
end
