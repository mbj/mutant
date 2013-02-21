require 'spec_helper'

describe Mutant::Matcher::Namespace, '#each' do
  subject { object.each { |item| yields << item } }

  let(:yields) { []                                    }
  let(:object) { described_class.new(TestApp::Literal) }

  let(:singleton_a) { mock('SingletonA', :name => 'TestApp::Literal') }
  let(:singleton_b) { mock('SingletonB', :name => 'TestApp::Foo')     }
  let(:subject_a)   { mock('SubjectA')                                }
  let(:subject_b)   { mock('SubjectB')                                }

  before do
    Mutant::Matcher::Methods::Singleton.stub(:each).with(singleton_a).and_yield(subject_a)
    Mutant::Matcher::Methods::Instance.stub(:each).with(singleton_a).and_yield(subject_b)
    ObjectSpace.stub(:each_object => [singleton_a, singleton_b])
  end

  it_should_behave_like 'an #each method'

  it 'should yield subjects' do
    expect { subject }.to change { yields }.from([]).to([subject_a, subject_b])
  end
end
