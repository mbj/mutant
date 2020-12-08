# frozen_string_literal: true

RSpec.describe Mutant::World do
  subject do
    Mutant::WORLD
  end

  describe '#inspect' do
    def apply
      subject.inspect
    end

    it 'returns expected value' do
      expect(apply).to eql('#<Mutant::World>')
    end

    it 'is frozen' do
      expect(apply.frozen?).to be(true)
    end

    it 'is idempotent' do
      expect(apply).to be(apply)
    end
  end

  describe '#capture_stdout' do
    def apply
      subject.capture_stdout(command)
    end

    let(:open3)          { class_double(Open3)              }
    let(:stdout)         { instance_double(String, :stdout) }
    let(:subject)        { super().with(open3: open3)       }
    let(:command)        { %w[foo bar baz]                  }

    let(:process_status) do
      instance_double(
        Process::Status,
        success?: success?
      )
    end

    before do
      allow(open3).to receive_messages(capture2: [stdout, process_status])
    end

    context 'when process exists successful' do
      let(:success?) { true }

      it 'returns stdout' do
        expect(apply).to eql(Mutant::Either::Right.new(stdout))
      end
    end

    context 'when process exists unsuccessful' do
      let(:success?) { false }

      it 'returns stdout' do
        expect(apply).to eql(Mutant::Either::Left.new("Command #{command.inspect} failed!"))
      end
    end
  end

  describe '#deadline' do
    def apply
      subject.deadline(allowed_time)
    end

    context 'on nil' do
      let(:allowed_time) { nil }

      it 'returns infinite deadline' do
        expect(apply).to eql(Mutant::Timer::Deadline::None.new)
      end
    end

    context 'on float' do
      let(:allowed_time) { 0.1 }

      it 'returns infinite deadline' do
        expect(apply).to eql(
          Mutant::Timer::Deadline.new(
            timer:        subject.timer,
            allowed_time: allowed_time
          )
        )
      end
    end
  end
end
