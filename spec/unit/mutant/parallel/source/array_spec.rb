# frozen_string_literal: true

RSpec.describe Mutant::Parallel::Source::Array do
  subject { described_class.new(payloads) }

  let(:payloads) { %i[a b c] }

  describe '#next' do
    def job(**attributes)
      Mutant::Parallel::Source::Job.new(attributes)
    end

    def apply
      subject.next
    end

    context 'when there is a next job' do
      it 'returns that job' do
        expect(apply).to eql(job(index: 0, payload: :a))
      end

      it 'does not return the same job twice' do
        expect(apply).to eql(job(index: 0, payload: :a))
        expect(apply).to eql(job(index: 1, payload: :b))
        expect(apply).to eql(job(index: 2, payload: :c))
      end
    end

    context 'when there is no next job' do
      let(:payloads) { [] }

      it 'raises error' do
        expect { apply }.to raise_error(Mutant::Parallel::Source::NoJobError)
      end
    end
  end

  describe '#next?' do
    def apply
      subject.next?
    end

    context 'when there is a next job' do
      it 'returns true' do
        expect(apply).to be(true)
      end
    end

    context 'when there is no next job' do
      let(:payloads) { [] }

      it 'returns false' do
        expect(apply).to be(false)
      end
    end
  end
end
