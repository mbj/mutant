# frozen_string_literal: true

RSpec.describe Mutant::Scope do
  describe '#unqualified_name' do
    subject { object.unqualified_name }

    let(:object) do
      Mutant::Scope.new(
        expression: instance_double(Mutant::Expression),
        raw:        raw_scope
      )
    end

    context 'with top level constant name' do
      let(:raw_scope) { TestApp }

      it 'should return the unqualified name' do
        should eql('TestApp')
      end

      it_should_behave_like 'an idempotent method'
    end

    context 'with scoped constant name' do
      let(:raw_scope) { TestApp::Literal }

      it 'should return the unqualified name' do
        should eql('Literal')
      end

      it_should_behave_like 'an idempotent method'
    end
  end
end
