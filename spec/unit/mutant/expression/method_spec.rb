# frozen_string_literal: true

RSpec.describe Mutant::Expression::Method do
  let(:object)           { parse_expression(input)   }
  let(:env)              { Fixtures::TEST_ENV        }
  let(:instance_method)  { 'TestApp::Literal#string' }
  let(:singleton_method) { 'TestApp::Literal.string' }

  describe '#match_length' do
    let(:input) { instance_method }

    subject { object.match_length(other) }

    context 'when other is an equivalent expression' do
      let(:other) { parse_expression(object.syntax) }

      it { should be(object.syntax.length) }
    end

    context 'when other is an unequivalent expression' do
      let(:other) { parse_expression('Foo*') }

      it { should be(0) }
    end
  end

  describe '#matcher' do
    subject { object.matcher }

    context 'with an instance method' do
      let(:input) { instance_method }

      it 'returns correct matcher' do
        expect(subject.call(env).map(&:expression)).to eql([object])
      end
    end

    context 'with a singleton method' do
      let(:input) { singleton_method }

      it 'returns correct matcher' do
        expect(subject.call(env).map(&:expression)).to eql([object])
      end
    end
  end
end
