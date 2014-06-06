# encoding: utf-8

require 'spec_helper'

describe Mutant::Matcher::Namespace do
  let(:object) { described_class.new(cache, 'TestApp::Literal') }
  let(:yields) { []                                             }

  let(:cache) { Mutant::Cache.new }

  subject { object.each { |item| yields << item } }

  describe '#each' do

    let(:singleton_a) { double('SingletonA', name: 'TestApp::Literal')      }
    let(:singleton_b) { double('SingletonB', name: 'TestApp::Foo')          }
    let(:singleton_c) { double('SingletonC', name: 'TestApp::LiteralOther') }
    let(:subject_a)   { double('SubjectA')                                  }
    let(:subject_b)   { double('SubjectB')                                  }

    before do
      Mutant::Matcher::Methods::Singleton.stub(:each)
        .with(cache, singleton_a)
        .and_yield(subject_a)
      Mutant::Matcher::Methods::Instance.stub(:each)
        .with(cache, singleton_a)
        .and_yield(subject_b)
      ObjectSpace.stub(each_object: [singleton_a, singleton_b, singleton_c])
    end

    context 'with no block' do
      subject { object.each }

      it { should be_instance_of(to_enum.class) }

      if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'rbx'
        pending 'FIX RBX rspec? BUG HERE'
      else
        it 'yields the expected values' do
          expect(subject.to_a).to eql(object.to_a)
        end
      end
    end

    it 'should yield subjects' do
      expect { subject }.to change { yields }.from([]).to([subject_a, subject_b])
    end
  end
end
