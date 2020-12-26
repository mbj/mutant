# frozen_string_literal: true

RSpec.describe Mutant::Transform::Exception do
  subject { described_class.new(error_class, block) }

  let(:error_class) do
    Class.new(RuntimeError)
  end

  describe '#call' do
    def apply
      subject.call(input)
    end

    let(:input) { 2 }

    context 'block that does not raise' do
      let(:block) { ->(input) { input * input } }

      it 'returns expected success value' do
        expect(apply).to eql(Mutant::Either::Right.new(4))
      end
    end

    context 'on block that raises' do
      context 'a covered exception' do
        let(:block) { ->(_input) { fail(error_class, 'some message') } }

        let(:error) do
          Mutant::Transform::Error.new(
            cause:     nil,
            input:     input,
            message:   'some message',
            transform: subject
          )
        end

        it 'returns expected error' do
          expect(apply).to eql(Mutant::Either::Left.new(error))
        end
      end
    end
  end
end
