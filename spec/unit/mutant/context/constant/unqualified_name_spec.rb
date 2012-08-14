require 'spec_helper'

describe Mutant::Context::Constant, '#unqualified_name' do
  subject { object.unqualified_name }

  let(:path)   { mock('Path')                                  }

  context 'with top level constant name' do
    let(:object) { described_class.build(path, TestApp) }

    it 'should return the unqualified name' do
      should eql('TestApp')
    end

    it_should_behave_like 'an idempotent method'
  end

  context 'with scoped constant name' do
    let(:object) { described_class.build(path, TestApp::Literal) }

    it 'should return the unqualified name' do
      should eql('Literal')
    end

    it_should_behave_like 'an idempotent method'
  end
end
