require 'spec_helper'

describe Mutant::Context::Scope, '#unqualified_name' do
  subject { object.unqualified_name }

  let(:path)   { mock('Path') }

  context 'with top level constant name' do
    let(:object) { described_class.build(TestApp, path) }

    it 'should return the unqualified name' do
      should eql('TestApp')
    end

    it_should_behave_like 'an idempotent method'
  end

  context 'with scoped constant name' do
    let(:object) { described_class.build(TestApp::Literal, path) }

    it 'should return the unqualified name' do
      should eql('Literal')
    end

    it_should_behave_like 'an idempotent method'
  end
end
