# encoding: utf-8

require 'spec_helper'

describe Mutant::Matcher::Chain do

  let(:object) { described_class.new(matchers) }

  describe '#each' do
    subject { object.each { |entry| yields << entry } }

    let(:matchers) { [matcher_a, matcher_b] }

    let(:matcher_a) { double('Matcher A') }
    let(:matcher_b) { double('Matcher B') }

    let(:subject_a) { double('Subject A') }
    let(:subject_b) { double('Subject B') }

    before do
      matcher_a.stub(:each).and_yield(subject_a).and_return(matcher_a)
      matcher_b.stub(:each).and_yield(subject_b).and_return(matcher_b)
    end

    # it_should_behave_like 'an #each method'
    context 'with no block' do
      subject { object.each }

      it { should be_instance_of(to_enum.class) }

      if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
        pending 'FIX RBX rspec? BUG HERE'
      else
        it 'yields the expected values' do
          subject.to_a.should eql(object.to_a)
        end
      end
    end

    let(:yields) { [] }

    it 'should yield subjects' do
      expect { subject }.to change { yields }.from([]).to([subject_a, subject_b])
    end
  end

  describe '#matchers' do
    subject { object.matchers }

    let(:matchers) { double('Matchers')            }

    it { should be(matchers) }

    it_should_behave_like 'an idempotent method'
  end

end
