require 'spec_helper'

describe Mutant::Expression::Methods do

  let(:object)            { described_class.parse(input) }
  let(:cache)             { Mutant::Cache.new            }
  let(:instance_methods)  { 'TestApp::Literal#'          }
  let(:singleton_methods) { 'TestApp::Literal.'          }

  describe '#match_length' do
    let(:input) { instance_methods }

    subject { object.match_length(other) }

    context 'when other is an equivalent expression' do
      let(:other) { described_class.parse(object.syntax) }

      it { should be(object.syntax.length) }
    end

    context 'when other is an unequivalent expression' do
      let(:other) { described_class.parse('Foo*') }

      it { should be(0) }
    end
  end

  describe '#matcher' do
    subject { object.matcher(cache) }

    context 'with an instance method' do
      let(:input) { instance_methods }

      it { should eql(Mutant::Matcher::Methods::Instance.new(cache, TestApp::Literal)) }
    end

    context 'with a singleton method' do
      let(:input) { singleton_methods }

      it { should eql(Mutant::Matcher::Methods::Singleton.new(cache, TestApp::Literal)) }
    end
  end
end
