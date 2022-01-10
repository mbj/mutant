# frozen_string_literal: true

RSpec.describe Mutant::Timer::Deadline do
  let(:object) do
    described_class.new(
      timer:        timer,
      allowed_time: allowed_time
    )
  end

  let(:timer) { instance_double(Mutant::Timer) }

  before do
    now = 1.0
    allow(timer).to receive(:now) do
      current = now
      now += 1
      current
    end
  end

  describe '#expired?' do
    def apply
      object.expired?
    end

    context 'when deadline has not yet expired' do
      let(:allowed_time) { 1.5 }

      it 'returns false' do
        expect(apply).to be(false)
      end
    end

    context 'when deadline has expired in the past' do
      let(:allowed_time) { 0.5 }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end

    context 'when deadline has expired just now' do
      let(:allowed_time) { 1.0 }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end
  end

  describe '#time_left' do
    def apply
      object.time_left
    end

    context 'when deadline has not yet expired' do
      let(:allowed_time) { 2.5 }

      it 'returns the time left' do
        expect(apply).to be(1.5)
        expect(apply).to be(0.5)
      end
    end

    context 'when deadline has expired' do
      let(:allowed_time) { 0.1 }

      it 'returns the time pased' do
        expect(apply).to be(-0.9)
      end
    end
  end

  describe '#status' do
    def apply
      object.status
    end

    context 'when deadline has not yet expired' do
      let(:allowed_time) { 1.5 }

      it 'returns status with time left' do
        expect(apply).to eql(described_class::Status.new(0.5))
      end
    end

    context 'when deadline has expired' do
      let(:allowed_time) { 0.5 }

      it 'returns status with time passed' do
        expect(apply).to eql(described_class::Status.new(-0.5))
      end
    end
  end
end

RSpec.describe Mutant::Timer::Deadline::Status do
  let(:object) { described_class.new(time_left) }

  describe '#ok?' do
    def apply
      object.ok?
    end

    context 'when there is time left' do
      let(:time_left) { 0.5 }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end

    context 'when there is no time left' do
      let(:time_left) { -0.5 }

      it 'returns true' do
        expect(apply).to be(false)
      end
    end

    context 'when there is no deadline' do
      let(:time_left) { nil }

      it 'returns true' do
        expect(apply).to be(true)
      end
    end
  end
end
RSpec.describe Mutant::Timer::Deadline::None do
  let(:object) { described_class.new }

  describe '#expired?' do
    def apply
      object.expired?
    end

    it 'returns false' do
      expect(apply).to be(false)
    end
  end

  describe '#time_left' do
    def apply
      object.time_left
    end

    it 'returns nil' do
      expect(apply).to be(nil)
    end
  end

  describe '#status' do
    def apply
      object.status
    end

    it 'returns endles status' do
      expect(apply).to eql(described_class::Status.new(nil))
    end
  end
end
