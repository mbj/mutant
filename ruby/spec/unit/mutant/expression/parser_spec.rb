# frozen_string_literal: true

RSpec.describe Mutant::Expression::Parser do
  subject do
    Mutant::Config::DEFAULT.expression_parser
  end

  def apply
    subject.call(input)
  end

  describe '#call' do
    context 'on a valid expression' do
      let(:input) { 'Foo' }

      it 'returns success' do
        expect(apply).to eql(
          Mutant::Either::Right.new(
            Mutant::Expression::Namespace::Exact.new(scope_name: 'Foo')
          )
        )
      end
    end

    context 'on invalid input' do
      let(:input) { 'foo bar' }

      it 'returns returns error' do
        expect(apply).to eql(
          Mutant::Either::Left.new('Expression: "foo bar" is invalid')
        )
      end
    end

    context 'on ambiguous input' do
      subject do
        described_class.new(types: [test_a, test_b])
      end

      let(:test_a) do
        Class.new(Mutant::Expression) do
          include Unparser::Anima.new

          const_set(:REGEXP, /\Atest-syntax\z/)
        end
      end

      let(:test_b) do
        Class.new(Mutant::Expression) do
          include Unparser::Anima.new

          const_set(:REGEXP, /^test-syntax$/)
        end
      end

      let(:input) { 'test-syntax' }

      it 'returns error' do
        expect(apply).to eql(
          Mutant::Either::Left.new(
            'Expression: "test-syntax" is ambiguous'
          )
        )
      end
    end
  end
end
