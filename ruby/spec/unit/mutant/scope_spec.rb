# frozen_string_literal: true

RSpec.describe Mutant::Scope do
  let(:object) do
    Mutant::Scope.new(
      expression: instance_double(Mutant::Expression),
      raw:        raw_scope
    )
  end

  describe '#unqualified_name' do
    subject { object.unqualified_name }

    context 'with top level constant name' do
      let(:raw_scope) { TestApp }

      it 'should return the unqualified name' do
        is_expected.to eql('TestApp')
      end

      it_behaves_like 'an idempotent method'
    end

    context 'with scoped constant name' do
      let(:raw_scope) { TestApp::Literal }

      it 'should return the unqualified name' do
        is_expected.to eql('Literal')
      end

      it_behaves_like 'an idempotent method'
    end
  end

  describe '#match_expressions' do
    subject { object.match_expressions }

    def recursive(scope_name)
      Mutant::Expression::Namespace::Recursive.new(scope_name:)
    end

    context 'with top level constant name' do
      let(:raw_scope) { TestApp }

      it 'returns single recursive expression' do
        is_expected.to eql([recursive('TestApp')])
      end

      it_behaves_like 'an idempotent method'
    end

    context 'with two level constant name' do
      let(:raw_scope) { TestApp::Literal }

      it 'returns expressions from most to least specific' do
        is_expected.to eql(
          [
            recursive('TestApp::Literal'),
            recursive('TestApp')
          ]
        )
      end

      it_behaves_like 'an idempotent method'
    end

    context 'with three level constant name' do
      let(:raw_scope) { double('scope', name: 'TestApp::Literal::Deep') }

      it 'returns expressions from most to least specific' do
        is_expected.to eql(
          [
            recursive('TestApp::Literal::Deep'),
            recursive('TestApp::Literal'),
            recursive('TestApp')
          ]
        )
      end

      it_behaves_like 'an idempotent method'
    end
  end
end
