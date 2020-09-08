# frozen_string_literal: true

RSpec.describe Mutant::Transform::Boolean do
  subject { described_class.new }

  describe '#apply' do
    def apply
      subject.apply(input)
    end

    context 'on true' do
      let(:input) { true }

      it 'returns sucess' do
        expect(apply).to eql(Mutant::Either::Right.new(input))
      end
    end

    context 'on false' do
      let(:input) { false }

      it 'returns sucess' do
        expect(apply).to eql(Mutant::Either::Right.new(input))
      end
    end

    context 'on nil input' do
      let(:input) { nil }

      let(:error) do
        Mutant::Transform::Error.new(
          cause:     nil,
          input:     input,
          message:   'Expected: boolean but got: nil',
          transform: subject
        )
      end

      it 'returns failure' do
        expect(apply).to eql(Mutant::Either::Left.new(error))
      end
    end

    context 'on truthy input' do
      let(:input) { '' }

      let(:error) do
        Mutant::Transform::Error.new(
          cause:     nil,
          input:     input,
          message:   'Expected: boolean but got: ""',
          transform: subject
        )
      end

      it 'returns failure' do
        expect(apply).to eql(Mutant::Either::Left.new(error))
      end
    end
  end
end
