require 'spec_helper'

# This method cannot be called directly, spec only exists for heckle demands
describe Mutant::Matcher::Method::Classifier,'#matcher' do
  subject { object.matcher }

  let(:object) { described_class.send(:new,match) }

  let(:match) { [mock,constant_name,scope_symbol,method_name] }

  let(:constant_name) { mock('Constant Name') }
  let(:method_name)   { 'foo'                  }

  context 'with "#" as scope symbol' do
    let(:scope_symbol) { '#' }

    it { should be_a(Mutant::Matcher::Method::Instance) }
    its(:method_name)   { should be(method_name.to_sym) }
    its(:constant_name) { should be(constant_name)      }
  end

  context 'with "." as scope symbol' do
    let(:scope_symbol) { '.' }

    it { should be_a(Mutant::Matcher::Method::Singleton) }
    its(:method_name)   { should be(method_name.to_sym)  }
    its(:constant_name) { should be(constant_name)       }
  end
end
